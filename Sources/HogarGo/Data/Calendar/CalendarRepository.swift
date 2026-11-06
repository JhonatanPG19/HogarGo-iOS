import Foundation
import SwiftData

enum CalendarError: Error {
    case emptyTitle
    case invalidAmount
    case unknown
}

/// Cálculos puros del calendario (sin base de datos).
enum CalendarMath {
    private static var calendar: Calendar { Calendar(identifier: .gregorian) }

    /// Primer día del mes mostrado: el mes actual desplazado `offset` meses.
    static func monthStart(offset: Int, now: Date = Date()) -> Date {
        let cal = calendar
        let comps = cal.dateComponents([.year, .month], from: now)
        let base = cal.date(from: comps) ?? now
        return cal.date(byAdding: .month, value: offset, to: base) ?? base
    }

    /// Celdas de la cuadrícula (semana desde domingo): vacías al inicio, días del mes y vacías hasta completar filas de 7.
    static func cells(monthStart: Date) -> [Date?] {
        let cal = calendar
        let weekday = cal.component(.weekday, from: monthStart) // 1 = domingo
        let leading = weekday - 1
        let dayCount = cal.range(of: .day, in: .month, for: monthStart)?.count ?? 30

        var result: [Date?] = Array(repeating: nil, count: leading)
        for day in 0..<dayCount {
            result.append(cal.date(byAdding: .day, value: day, to: monthStart))
        }
        while result.count % 7 != 0 { result.append(nil) }
        return result
    }

    static func year(of date: Date) -> Int { calendar.component(.year, from: date) }
    static func monthIndex(of date: Date) -> Int { calendar.component(.month, from: date) - 1 }
}

/// Facturas y eventos del hogar.
@MainActor
final class CalendarRepository {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Lecturas

    /// Facturas del hogar por fecha de vencimiento ascendente.
    func bills(householdId: String) -> [Bill] {
        let descriptor = FetchDescriptor<Bill>(
            predicate: #Predicate { $0.householdId == householdId },
            sortBy: [SortDescriptor(\.dueDateISO, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func events(householdId: String) -> [CalendarEvent] {
        let descriptor = FetchDescriptor<CalendarEvent>(
            predicate: #Predicate { $0.householdId == householdId }
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Tareas completadas del hogar (solo se leen: el calendario las muestra como puntos verdes).
    func completedTasks(householdId: String) -> [HouseholdTask] {
        let descriptor = FetchDescriptor<HouseholdTask>(
            predicate: #Predicate { $0.householdId == householdId && $0.completed }
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - Facturas

    @discardableResult
    func addBill(householdId: String, title rawTitle: String, amount: Double?, dueDateISO: String) throws -> Bill {
        let title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw CalendarError.emptyTitle }
        guard let amount, amount > 0 else { throw CalendarError.invalidAmount }

        let bill = Bill(householdId: householdId, title: title, amount: amount, dueDateISO: dueDateISO)
        context.insert(bill)
        try saveContext()
        return bill
    }

    func toggleBillPaid(_ bill: Bill) throws {
        bill.paid.toggle()
        try saveContext()
    }

    func deleteBill(_ bill: Bill) throws {
        context.delete(bill)
        try saveContext()
    }

    // MARK: - Eventos

    @discardableResult
    func addEvent(householdId: String, title rawTitle: String, dateISO: String, timeLabel: String?) throws -> CalendarEvent {
        let title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw CalendarError.emptyTitle }

        let event = CalendarEvent(householdId: householdId, title: title, dateISO: dateISO, timeLabel: timeLabel)
        context.insert(event)
        try saveContext()
        return event
    }

    func toggleEventDone(_ event: CalendarEvent) throws {
        event.done.toggle()
        try saveContext()
    }

    func deleteEvent(_ event: CalendarEvent) throws {
        context.delete(event)
        try saveContext()
    }

    // MARK: - Privado

    private func saveContext() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw CalendarError.unknown
        }
    }
}
