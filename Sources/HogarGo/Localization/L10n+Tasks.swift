import Foundation

/// Textos de Tareas e Inicio (ES / EN).
extension L10n {
    // MARK: Fecha de una tarea
    static var taskDateToday: String { tr("Hoy", "Today") }
    static var taskDateTomorrow: String { tr("Mañana", "Tomorrow") }
    static var taskDateWeekend: String { tr("Fin de semana", "Weekend") }
    static func taskDueAt(_ time: String) -> String { tr("Para las \(time)", "Due at \(time)") }

    // MARK: Inicio y racha
    static func homeGreeting(_ name: String?) -> String {
        tr("¡Hola, \(name ?? "Familia")!", "Hi, \(name ?? "Family")!")
    }

    /// "Racha de 3/7 días". El tope visual es 7 aunque la racha real sea mayor.
    static func homeStreak(_ days: Int, atRisk: Bool) -> String {
        let shown = min(days, 7)
        let warning = atRisk ? " ⚠️" : ""
        return tr("Racha de \(shown)/7 días\(warning)", "\(shown)/7-day streak\(warning)")
    }

    /// Texto del banner de la pestaña Tareas. El aviso ⚠️ sale con cualquier racha en riesgo.
    static func streakBanner(_ days: Int, atRisk: Bool) -> String {
        let warning = atRisk ? " ⚠️" : ""
        switch days {
        case 0: return tr("¡Empieza tu racha hoy!", "Start your streak today!")
        case 1: return tr("¡1 Día Activo!", "1 Active Day!") + warning
        default: return tr("¡\(days) Días Seguidos!", "\(days) Days in a Row!") + warning
        }
    }
}

/// Fecha elegida en "Nueva Tarea".
enum TaskDateOption: CaseIterable, Identifiable {
    case today
    case tomorrow
    case weekend

    var id: Self { self }

    var label: String {
        switch self {
        case .today: return L10n.taskDateToday
        case .tomorrow: return L10n.taskDateTomorrow
        case .weekend: return L10n.taskDateWeekend
        }
    }

    /// Fecha ISO "yyyy-MM-dd". "Fin de semana" es el próximo sábado (o hoy si ya es sábado o domingo).
    var dateISO: String {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        switch self {
        case .today:
            return ISODay.string(from: now)
        case .tomorrow:
            return ISODay.string(from: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
        case .weekend:
            let weekday = calendar.component(.weekday, from: now) // 1 = domingo ... 7 = sábado
            let daysToSaturday = (weekday == 1 || weekday == 7) ? 0 : 7 - weekday
            return ISODay.string(from: calendar.date(byAdding: .day, value: daysToSaturday, to: now) ?? now)
        }
    }
}

extension HouseholdTask {
    /// "Para las 18:00" si es hoy (o no tiene fecha); "12 nov • 18:00" en otro día.
    var dueLabel: String? {
        guard let time = dueTime else { return nil }
        guard let dateISO = dueDateISO, dateISO != ISODay.today() else {
            return L10n.taskDueAt(time)
        }
        return ISODay.short(dateISO) + " • " + time
    }
}
