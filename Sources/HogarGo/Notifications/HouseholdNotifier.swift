import Foundation
import UserNotifications

/// Muestra los avisos del hogar como notificaciones locales ("Novedades del hogar")
/// y programa el recordatorio diario de racha a las 20:00 (sección 17 de AGENTS.md).
@MainActor
final class HouseholdNotifier: NSObject, UNUserNotificationCenterDelegate {
    static let categoryId = "household_updates"
    static let streakReminderId = "daily_streak_reminder"

    private var center: UNUserNotificationCenter { .current() }

    func setUp() {
        center.delegate = self
        center.setNotificationCategories([
            UNNotificationCategory(identifier: Self.categoryId, actions: [], intentIdentifiers: [])
        ])
    }

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// Programa o actualiza el recordatorio diario de racha a las 20:00.
    func updateStreakReminder(hasPendingTasks: Bool, isStreakAtRisk: Bool) {
        center.removePendingNotificationRequests(withIdentifiers: [Self.streakReminderId])
        guard hasPendingTasks || isStreakAtRisk else { return }

        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "¡Mantén tu racha en HogarGo! 🔥"
        content.body = isStreakAtRisk
            ? "Tu racha diaria está en riesgo. Completa una tarea antes de que termine el día."
            : "Tienes tareas pendientes en el hogar. ¡Haz que tu casa brille hoy!"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: Self.streakReminderId, content: content, trigger: trigger)
        center.add(request)
    }

    /// Si no hay permiso, el aviso igual se considera entregado (lo decide quien llama).
    func show(_ notice: HouseholdNotice) {
        guard let (title, body) = Self.text(for: notice) else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = Self.categoryId
        content.threadIdentifier = Self.categoryId
        center.add(UNNotificationRequest(identifier: notice.id, content: content, trigger: nil))
    }

    static func text(for notice: HouseholdNotice) -> (String, String)? {
        let a = notice.arg1, b = notice.arg2
        switch notice.noticeType {
        case .renamed:
            return (L10n.tr("Cambió el nombre del hogar", "The home was renamed"),
                    L10n.tr("«\(a)» ahora se llama «\(b)»", "“\(a)” is now called “\(b)”"))
        case .joinRequest:
            return (L10n.tr("Nueva solicitud de ingreso", "New join request"),
                    L10n.tr("\(a) quiere unirse a \(b). Acéptalo desde tu perfil.", "\(a) wants to join \(b). Accept them from your profile."))
        case .joined:
            return (L10n.tr("Nuevo integrante", "New member"),
                    L10n.tr("\(a) se unió al hogar.", "\(a) joined the home."))
        case .left:
            return (L10n.tr("Alguien salió del hogar", "Someone left the home"),
                    L10n.tr("\(a) salió del hogar.", "\(a) left the home."))
        case .memberRemoved:
            return (L10n.tr("Cambios en el hogar", "Home changes"),
                    L10n.tr("\(a) fue eliminado del hogar.", "\(a) was removed from the home."))
        case .admin:
            return (L10n.tr("Ahora eres administrador", "You're now the admin"),
                    L10n.tr("Quien administraba \(a) salió, y ahora tú eres el admin.", "The person who managed \(a) left, and now you're the admin."))
        case .removed, .none:
            return nil
        }
    }

    // Mostrar el aviso también con la app abierta. Tocarlo solo abre la app.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
