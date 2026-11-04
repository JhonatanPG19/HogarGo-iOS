import Foundation
import Observation
import SwiftData

/// Estado global: quién tiene la sesión abierta y en qué hogar.
@MainActor
@Observable
final class AppState {
    enum Phase: Equatable {
        /// Restaurando la sesión (pantalla vacía para no parpadear).
        case loading
        case welcome
        case signedIn(memberId: String, householdId: String)
    }

    private(set) var phase: Phase = .loading
    /// Mensaje breve tipo "toast".
    var toast: String?

    let repository: HouseholdRepository
    let taskRepository: TaskRepository
    let financeRepository: FinanceRepository
    let petRepository: PetRepository
    private let session: SessionStore
    private let notifier: HouseholdNotifier
    @ObservationIgnored private var saveObserver: NSObjectProtocol?
    @ObservationIgnored private var toastTask: Task<Void, Never>?
    @ObservationIgnored private var isDelivering = false

    init(context: ModelContext, session: SessionStore = SessionStore(), notifier: HouseholdNotifier = HouseholdNotifier()) {
        self.repository = HouseholdRepository(context: context)
        self.taskRepository = TaskRepository(context: context)
        self.financeRepository = FinanceRepository(context: context)
        self.petRepository = PetRepository(context: context)
        self.session = session
        self.notifier = notifier
        notifier.setUp()
        saveObserver = NotificationCenter.default.addObserver(
            forName: ModelContext.didSave, object: context, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
    }

    var memberId: String? {
        if case let .signedIn(memberId, _) = phase { return memberId }
        return nil
    }

    var householdId: String? {
        if case let .signedIn(_, householdId) = phase { return householdId }
        return nil
    }

    /// Integrante vivo en la base (el rol de admin se lee de aquí, no de la sesión).
    var currentMember: Member? { memberId.flatMap(repository.member(id:)) }
    var currentHousehold: Household? { householdId.flatMap(repository.household(id:)) }

    /// Racha actual de tareas del hogar activo.
    var currentStreak: StreakInfo {
        guard let householdId else {
            return StreakInfo(days: 0, isAtRisk: false, hasCompletedToday: false)
        }
        return taskRepository.streakInfo(householdId: householdId)
    }

    // MARK: - Sesión

    func restore() {
        guard let saved = session.load(),
              let member = repository.member(id: saved.memberId),
              member.householdId == saved.householdId,
              member.isApproved,
              repository.household(id: saved.householdId) != nil else {
            session.clear()
            phase = .welcome
            return
        }
        start(member)
    }

    func start(_ member: Member) {
        session.save(.init(memberId: member.id, householdId: member.householdId))
        phase = .signedIn(memberId: member.id, householdId: member.householdId)
        notifier.requestAuthorization()
        taskRepository.seedInitialTasksIfNeeded(householdId: member.householdId)
        deliverPendingNotices()
        syncStreakReminder()
    }

    /// Cierra la sesión del dispositivo. Sigues siendo integrante y los datos se conservan.
    func logout() {
        session.clear()
        phase = .welcome
    }

    /// Salir del hogar: primero se cierra la sesión para que la UI no reaccione
    /// a que "mi fila desapareció".
    func leaveHousehold() throws {
        guard let memberId else { return }
        logout()
        try repository.leaveHousehold(memberId: memberId)
    }

    // MARK: - Notificaciones locales de racha

    /// Sincroniza el recordatorio de las 20:00 con el estado actual de tareas y racha.
    func syncStreakReminder() {
        guard let householdId else { return }
        let hasPending = taskRepository.nextPendingTask(householdId: householdId) != nil
        let atRisk = currentStreak.isAtRisk
        notifier.updateStreakReminder(hasPendingTasks: hasPending, isStreakAtRisk: atRisk)
    }

    // MARK: - Cambios en la base

    private func refresh() {
        guard case let .signedIn(memberId, householdId) = phase else { return }
        if repository.member(id: memberId) == nil {
            // Me eliminaron con la app abierta.
            if !repository.members(householdId: householdId).isEmpty || repository.household(id: householdId) == nil {
                logout()
            }
            return
        }
        deliverPendingNotices()
        syncStreakReminder()
    }

    private func deliverPendingNotices() {
        guard let memberId, !isDelivering else { return }
        isDelivering = true
        defer { isDelivering = false }
        for notice in repository.pendingNotices(memberId: memberId) {
            // Solo quien reclama el aviso lo muestra: así nunca se duplica.
            // Sin permiso de notificaciones igual queda como entregado.
            if repository.claim(noticeId: notice.id) {
                notifier.show(notice)
            }
        }
    }

    // MARK: - Toast

    func showToast(_ message: String) {
        toast = message
        toastTask?.cancel()
        toastTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            self?.toast = nil
        }
    }
}
