import Foundation
import Observation

/// ViewModel de Tareas (MVVM). Mismas reglas que los demás ViewModels:
/// datos en propiedades `@Observable`, `reload()` tras cada acción y suscripción a `didSave`.
@MainActor
@Observable
final class TasksViewModel {
    // MARK: Estado que observa la vista

    /// Tareas del hogar: pendientes primero (más recientes arriba) y luego las completadas.
    private(set) var tasks: [HouseholdTask] = []
    /// Nombre de cada integrante por id, para mostrar quién es el responsable de cada tarea.
    /// Se carga en `reload()` (no se consulta dentro de `body`, que era el origen del bug de listas viejas).
    private(set) var memberNames: [String: String] = [:]

    // MARK: Dependencias

    let householdId: String
    @ObservationIgnored private let taskRepository: TaskRepository
    @ObservationIgnored private let householdRepository: HouseholdRepository
    @ObservationIgnored private var observer: SaveObserver?

    init(householdId: String, taskRepository: TaskRepository, householdRepository: HouseholdRepository) {
        self.householdId = householdId
        self.taskRepository = taskRepository
        self.householdRepository = householdRepository
    }

    func start() {
        guard observer == nil else { return }
        observer = SaveObserver(context: householdRepository.context) { [weak self] in
            self?.reload()
        }
        reload()
    }

    func reload() {
        tasks = taskRepository.tasks(householdId: householdId)
        memberNames = Dictionary(
            uniqueKeysWithValues: householdRepository.members(householdId: householdId).map { ($0.id, $0.name) }
        )
    }

    // MARK: Estado derivado

    /// Racha del hogar calculada con las fechas de las tareas completadas.
    var streak: StreakInfo {
        StreakCalculator.calculate(completedDates: tasks.filter(\.completed).compactMap(\.completedDate))
    }

    func assigneeName(for memberId: String?) -> String? {
        memberId.flatMap { memberNames[$0] }
    }

    // MARK: Acciones

    func toggle(_ task: HouseholdTask) {
        _ = try? taskRepository.toggleTask(id: task.id)
        reload()
    }
}
