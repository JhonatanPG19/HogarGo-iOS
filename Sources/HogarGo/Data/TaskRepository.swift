import Foundation
import SwiftData

/// Repositorio de tareas del hogar: operaciones de consulta, creación,
/// completado y eliminación con persistencia en SwiftData.
@MainActor
final class TaskRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Consultas

    /// Todas las tareas de un hogar, ordenadas: pendientes primero, luego más recientes.
    func tasks(householdId: String) -> [HouseholdTask] {
        // SwiftData no permite ordenar por un Bool: se trae por fecha y se separan en memoria.
        let descriptor = FetchDescriptor<HouseholdTask>(
            predicate: #Predicate { $0.householdId == householdId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let all = (try? context.fetch(descriptor)) ?? []
        return all.filter { !$0.completed } + all.filter(\.completed)
    }

    /// Tarea por id.
    func task(id: String) -> HouseholdTask? {
        var descriptor = FetchDescriptor<HouseholdTask>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    /// Siguiente tarea pendiente para la tarjeta de Inicio.
    func nextPendingTask(householdId: String) -> HouseholdTask? {
        var descriptor = FetchDescriptor<HouseholdTask>(
            predicate: #Predicate { $0.householdId == householdId && !$0.completed },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    /// Fechas ISO ("yyyy-MM-dd") de todas las tareas completadas en el hogar (para el cálculo de racha).
    func completedDates(householdId: String) -> [String] {
        let descriptor = FetchDescriptor<HouseholdTask>(
            predicate: #Predicate { $0.householdId == householdId && $0.completed }
        )
        let tasks = (try? context.fetch(descriptor)) ?? []
        return tasks.compactMap(\.completedDate)
    }

    /// Calcula la información de racha actual para el hogar.
    func streakInfo(householdId: String) -> StreakInfo {
        let dates = completedDates(householdId: householdId)
        return StreakCalculator.calculate(completedDates: dates)
    }

    // MARK: - Modificaciones

    /// Crea y persiste una nueva tarea en el hogar.
    @discardableResult
    func createTask(
        householdId: String,
        title rawTitle: String,
        category: TaskCategory = .general,
        dueTime: String? = "18:00",
        dueDateISO: String? = nil,
        assigneeId: String? = nil,
        coinReward: Int = 10
    ) throws -> HouseholdTask {
        let title = rawTitle.trimmed
        guard !title.isEmpty else { throw HogarError.emptyTaskTitle }

        let task = HouseholdTask(
            householdId: householdId,
            title: title,
            category: category,
            dueTime: dueTime,
            dueDateISO: dueDateISO,
            completed: false,
            completedDate: nil,
            assigneeId: assigneeId,
            coinReward: coinReward
        )
        context.insert(task)
        try saveContext()
        return task
    }

    /// Alterna el estado de completado de una tarea.
    /// Si pasa a completada, registra la fecha actual "yyyy-MM-dd" para la racha.
    @discardableResult
    func toggleTask(id: String) throws -> HouseholdTask {
        guard let task = task(id: id) else { throw HogarError.taskNotFound }

        task.completed.toggle()
        if task.completed {
            task.completedDate = TaskDateHelper.todayString()
        } else {
            task.completedDate = nil
        }
        try saveContext()
        return task
    }

    /// Elimina una tarea de la base de datos.
    func deleteTask(id: String) throws {
        guard let task = task(id: id) else { throw HogarError.taskNotFound }
        context.delete(task)
        try saveContext()
    }

    /// Si el hogar no tiene ninguna tarea registrada, siembra las 3 tareas iniciales de ejemplo.
    func seedInitialTasksIfNeeded(householdId: String) {
        guard tasks(householdId: householdId).isEmpty else { return }

        let samples: [(String, TaskCategory, String, Int)] = [
            ("Vaciar el Lavavajillas", .kitchen, "17:00", 15),
            ("Regar los Tomates", .garden, "10:00", 20),
            ("Doblar la Ropa", .general, "18:00", 30)
        ]

        for (title, cat, due, coins) in samples {
            let task = HouseholdTask(
                householdId: householdId,
                title: title,
                category: cat,
                dueTime: due,
                completed: false,
                completedDate: nil,
                assigneeId: nil,
                coinReward: coins
            )
            context.insert(task)
        }
        try? saveContext()
    }

    // MARK: - Privado

    private func saveContext() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw HogarError.unknown
        }
    }
}

/// Utilidades de formato de fecha para tareas y cálculo de rachas.
enum TaskDateHelper {
    static let isoFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current
        return df
    }()

    static func todayString() -> String {
        isoFormatter.string(from: Date())
    }

    static func date(from isoString: String) -> Date? {
        isoFormatter.date(from: isoString)
    }
}

