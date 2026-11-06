import Foundation
import Observation

/// ViewModel de Inicio (MVVM). Además de las tareas y la racha, **es quien llama al servicio
/// externo**: la vista ya no habla con `AdviceService`, solo muestra `advice` e `isFetchingAdvice`.
/// Mismas reglas de refresco: propiedades `@Observable`, `reload()` tras cada acción y `didSave`.
@MainActor
@Observable
final class HomeViewModel {
    // MARK: Estado que observa la vista

    private(set) var tasks: [HouseholdTask] = []
    private(set) var members: [Member] = []
    /// Consejo del día. Empieza con el mensaje de respaldo y se reemplaza al llegar la respuesta de la API.
    private(set) var advice = AdviceService.fallbackAdvice
    private(set) var isFetchingAdvice = false

    // MARK: Dependencias

    let householdId: String
    /// Integrante que tiene la sesión abierta (para el saludo).
    let memberId: String?
    @ObservationIgnored private let taskRepository: TaskRepository
    @ObservationIgnored private let householdRepository: HouseholdRepository
    @ObservationIgnored private let adviceService: AdviceService
    @ObservationIgnored private var observer: SaveObserver?

    init(
        householdId: String,
        memberId: String?,
        taskRepository: TaskRepository,
        householdRepository: HouseholdRepository,
        adviceService: AdviceService = .shared
    ) {
        self.householdId = householdId
        self.memberId = memberId
        self.taskRepository = taskRepository
        self.householdRepository = householdRepository
        self.adviceService = adviceService
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
        members = householdRepository.approvedMembers(householdId: householdId)
    }

    // MARK: Estado derivado

    /// La tarea pendiente más antigua (la que muestra "Siguiente tarea").
    var nextPendingTask: HouseholdTask? {
        tasks.filter { !$0.completed }.min { $0.createdAt < $1.createdAt }
    }

    /// Nombre de quien tiene la sesión (se actualiza si se cambia el nombre desde el perfil).
    var currentMemberName: String? {
        members.first { $0.id == memberId }?.name
    }

    var streak: StreakInfo {
        StreakCalculator.calculate(completedDates: tasks.filter(\.completed).compactMap(\.completedDate))
    }

    /// Texto del cuadro "Integrantes del Hogar".
    var membersSummary: String {
        guard !members.isEmpty else {
            return L10n.tr("No hay integrantes registrados en este hogar todavía.",
                           "There are no members registered in this home yet.")
        }
        let lines = members.map { "• \($0.name)\($0.isAdmin ? " (" + L10n.adminBadge + ")" : "")" }
        let title = L10n.tr("Miembros registrados en la familia:", "Registered family members:")
        return ([title] + lines).joined(separator: "\n")
    }

    // MARK: Acciones

    /// Completa exactamente la tarea que muestra la tarjeta.
    func toggleNextTask() {
        guard let task = nextPendingTask else { return }
        _ = try? taskRepository.toggleTask(id: task.id)
        reload()
    }

    /// Pide el consejo solo si todavía no se obtuvo uno de la API.
    func loadAdviceIfNeeded() async {
        if advice == AdviceService.fallbackAdvice {
            await refreshAdvice()
        }
    }

    /// Consulta la API (`AdviceService`) y actualiza `advice`; si falla, queda el mensaje de respaldo.
    func refreshAdvice() async {
        isFetchingAdvice = true
        advice = await adviceService.fetchDailyAdvice()
        isFetchingAdvice = false
    }
}
