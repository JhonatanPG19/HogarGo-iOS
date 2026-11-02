import Foundation

/// Información del estado de racha de tareas del hogar.
struct StreakInfo: Equatable {
    /// Número de días consecutivos con al menos una tarea completada.
    let days: Int
    /// Verdadero si hay una racha activa (> 0 días) pero aún no se completa ninguna tarea hoy.
    let isAtRisk: Bool
    /// Verdadero si hoy ya se completó al menos una tarea.
    let hasCompletedToday: Bool
}

/// Motor de cálculo de rachas diarias para HogarGo.
///
/// Lógica basada en la especificación del proyecto:
/// 1. Si el integrante completó una tarea hoy, el día actual cuenta como activo.
/// 2. Si no completó ninguna hoy, pero completó una ayer, se mantiene la racha.
/// 3. Si no hay finalizaciones hoy ni ayer, la racha actual es 0.
/// 4. Se considera en riesgo si la racha es positiva y aún no se completa una tarea hoy.
/// 5. Múltiples tareas completadas el mismo día cuentan como 1 solo día de racha.
enum StreakCalculator {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    private static var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        return cal
    }

    /// Retorna la fecha como string "yyyy-MM-dd" en la zona horaria local.
    static func dateString(from date: Date = Date()) -> String {
        dateFormatter.string(from: date)
    }

    /// Calcula la racha a partir de una lista de fechas ISO ("yyyy-MM-dd") de tareas completadas.
    ///
    /// - Parameters:
    ///   - completedDates: Fechas en formato "yyyy-MM-dd".
    ///   - referenceDate: Fecha base para el cálculo (por defecto ahora).
    /// - Returns: `StreakInfo` con los días, si está en riesgo y si se completó hoy.
    static func calculate(completedDates: [String], referenceDate: Date = Date()) -> StreakInfo {
        let uniqueDays = Set(
            completedDates
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        )

        guard !uniqueDays.isEmpty else {
            return StreakInfo(days: 0, isAtRisk: false, hasCompletedToday: false)
        }

        let cal = calendar
        guard let todayNormalized = cal.date(from: cal.dateComponents([.year, .month, .day], from: referenceDate)) else {
            return StreakInfo(days: 0, isAtRisk: false, hasCompletedToday: false)
        }

        let todayStr = dateString(from: todayNormalized)
        let completedToday = uniqueDays.contains(todayStr)

        var streak = 0
        var checkDate = todayNormalized

        if !completedToday {
            // Verificar si completó ayer
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: todayNormalized) else {
                return StreakInfo(days: 0, isAtRisk: false, hasCompletedToday: false)
            }
            let yesterdayStr = dateString(from: yesterday)
            if !uniqueDays.contains(yesterdayStr) {
                // Sin tareas ni hoy ni ayer -> racha 0
                return StreakInfo(days: 0, isAtRisk: false, hasCompletedToday: false)
            }
            // Ayer completó: evaluamos hacia atrás desde ayer
            checkDate = yesterday
        }

        // Contar días consecutivos hacia atrás
        while true {
            let dayStr = dateString(from: checkDate)
            if uniqueDays.contains(dayStr) {
                streak += 1
                guard let previousDay = cal.date(byAdding: .day, value: -1, to: checkDate) else {
                    break
                }
                checkDate = previousDay
            } else {
                break
            }
        }

        let isAtRisk = (streak > 0) && !completedToday

        return StreakInfo(
            days: streak,
            isAtRisk: isAtRisk,
            hasCompletedToday: completedToday
        )
    }

    /// Días de racha calculados.
    static func streakDays(completedDates: [String], referenceDate: Date = Date()) -> Int {
        calculate(completedDates: completedDates, referenceDate: referenceDate).days
    }

    /// Indica si la racha está en riesgo hoy.
    static func isAtRisk(completedDates: [String], referenceDate: Date = Date()) -> Bool {
        calculate(completedDates: completedDates, referenceDate: referenceDate).isAtRisk
    }
}

