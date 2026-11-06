import Foundation
import Observation

/// Punto de color que se dibuja bajo un día de la cuadrícula.
enum CalendarDot: Equatable {
    /// Factura sin pagar que ya venció o vence hoy.
    case overdueBill
    /// Factura sin pagar con vencimiento futuro.
    case upcomingBill
    case event
    case task
}

/// ViewModel de Calendario (MVVM). Mismas reglas que `FinanceViewModel`:
/// datos en propiedades `@Observable`, `reload()` tras cada acción y suscripción a `didSave`.
/// Las tareas completadas se completan en otra pantalla y aquí solo se leen, por eso la
/// suscripción a `didSave` es la que mantiene los puntos verdes al día.
@MainActor
@Observable
final class CalendarViewModel {
    // MARK: Estado que observa la vista

    private(set) var bills: [Bill] = []
    private(set) var events: [CalendarEvent] = []
    private(set) var completedTasks: [HouseholdTask] = []

    // MARK: Dependencias

    let householdId: String
    @ObservationIgnored private let repository: CalendarRepository
    @ObservationIgnored private var observer: SaveObserver?

    init(householdId: String, repository: CalendarRepository) {
        self.householdId = householdId
        self.repository = repository
    }

    func start() {
        guard observer == nil else { return }
        observer = SaveObserver(context: repository.context) { [weak self] in
            self?.reload()
        }
        reload()
    }

    func reload() {
        bills = repository.bills(householdId: householdId)
        events = repository.events(householdId: householdId)
        completedTasks = repository.completedTasks(householdId: householdId)
    }

    // MARK: Estado derivado

    /// Hasta 3 puntos por día, en este orden: factura, evento y tarea completada.
    func dots(for iso: String, today: String = ISODay.today()) -> [CalendarDot] {
        var dots: [CalendarDot] = []

        let dueBills = bills.filter { $0.dueDateISO == iso && !$0.paid }
        if !dueBills.isEmpty {
            dots.append(dueBills.contains { $0.dueDateISO <= today } ? .overdueBill : .upcomingBill)
        }
        if events.contains(where: { $0.dateISO == iso }) {
            dots.append(.event)
        }
        if completedTasks.contains(where: { $0.completedDate == iso }) {
            dots.append(.task)
        }
        return dots
    }

    /// Eventos de un día ordenados por hora.
    func eventsOn(_ iso: String) -> [CalendarEvent] {
        events
            .filter { $0.dateISO == iso }
            .sorted { ($0.timeLabel ?? "") < ($1.timeLabel ?? "") }
    }

    func billsDueOn(_ iso: String) -> [Bill] {
        bills.filter { $0.dueDateISO == iso }
    }

    func tasksCompletedOn(_ iso: String) -> [HouseholdTask] {
        completedTasks.filter { $0.completedDate == iso }
    }

    /// Eventos de hoy en adelante, por fecha y luego por hora.
    func upcomingEvents(today: String = ISODay.today()) -> [CalendarEvent] {
        events
            .filter { $0.dateISO >= today }
            .sorted {
                if $0.dateISO != $1.dateISO { return $0.dateISO < $1.dateISO }
                return ($0.timeLabel ?? "") < ($1.timeLabel ?? "")
            }
    }

    // MARK: Acciones

    func toggleEventDone(_ event: CalendarEvent) {
        try? repository.toggleEventDone(event)
        reload()
    }

    func deleteEvent(_ event: CalendarEvent) {
        try? repository.deleteEvent(event)
        reload()
    }

    func toggleBillPaid(_ bill: Bill) {
        try? repository.toggleBillPaid(bill)
        reload()
    }

    func deleteBill(_ bill: Bill) {
        try? repository.deleteBill(bill)
        reload()
    }
}
