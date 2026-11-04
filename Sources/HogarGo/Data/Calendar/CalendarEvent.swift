import Foundation
import SwiftData

/// Evento del hogar. La fecha es siempre real (ISO) y la hora es opcional ("HH:mm").
@Model
final class CalendarEvent {
    var id: String
    var householdId: String
    var title: String
    var dateISO: String
    var timeLabel: String?
    var done: Bool

    init(
        id: String = UUID().uuidString,
        householdId: String,
        title: String,
        dateISO: String,
        timeLabel: String? = nil,
        done: Bool = false
    ) {
        self.id = id
        self.householdId = householdId
        self.title = title
        self.dateISO = dateISO
        self.timeLabel = timeLabel
        self.done = done
    }
}
