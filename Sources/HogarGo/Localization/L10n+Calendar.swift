import Foundation

/// Textos del Calendario (ES / EN).
extension L10n {
    static var calendarTitle: String { tr("Calendario", "Calendar") }
    static var calendarSubtitle: String {
        tr("Un resumen cálido de los ritmos de tu mes.", "A warm summary of your month's rhythm.")
    }
    static func calendarMonthYear(_ month: String, _ year: Int) -> String { "\(month) \(year)" }
    static var calendarPrevMonth: String { tr("Mes anterior", "Previous month") }
    static var calendarNextMonth: String { tr("Mes siguiente", "Next month") }
    static var calendarLegendEvents: String { tr("Eventos", "Events") }
    static var calendarLegendBills: String { tr("Facturas", "Bills") }
    static var calendarLegendTasks: String { tr("Tareas", "Tasks") }
    static var calendarDayEvents: String { tr("Eventos", "Events") }
    static var calendarDayBills: String { tr("Facturas que vencen", "Bills due") }
    static var calendarDayTasks: String { tr("Tareas completadas", "Completed tasks") }
    static var calendarDayEmpty: String { tr("No hay nada asignado a este día.", "Nothing is scheduled for this day.") }
    static var calendarUpcoming: String { tr("Próximos Eventos", "Upcoming Events") }
    static var calendarEventsEmpty: String { tr("No hay eventos programados.", "No events scheduled.") }
    static var calendarAddEvent: String { tr("Nuevo Evento", "New Event") }
    static var calendarEventNameLabel: String { tr("Nombre del evento", "Event name") }
    static var calendarEventNameHint: String {
        tr("Ej. Cumpleaños de Leo, Cita médica", "E.g. Leo's birthday, Doctor appointment")
    }
    static var calendarEventDateLabel: String { tr("Fecha", "Date") }
    static var calendarEventTimeLabel: String { tr("Hora", "Time") }
    static var calendarEventCreate: String { tr("Crear", "Create") }
    static var calendarDeleteEvent: String { tr("Eliminar evento", "Delete event") }
    static var calendarBillsDue: String { tr("Vencimiento de Facturas", "Bills Due") }
    static var calendarDueToday: String { tr("¡Vence Hoy!", "Due Today!") }
    static var calendarAddBill: String { tr("Nueva Factura", "New Bill") }
    static var calendarBillNameLabel: String { tr("Nombre", "Name") }
    static var calendarBillNameHint: String { tr("Ej: Internet", "E.g.: Internet") }
    static var calendarBillDueDateLabel: String { tr("Fecha de vencimiento", "Due date") }
    static var calendarBillsEmpty: String {
        tr("Aún no tienes facturas registradas. Toca + para añadir la primera.",
           "No bills yet. Tap + to add the first one.")
    }
    static var calendarDeleteBill: String { tr("Eliminar factura", "Delete bill") }
    static var calendarBillAmountLabel: String { tr("Monto", "Amount") }

    static var calendarMonths: [String] {
        isEnglish
            ? ["January", "February", "March", "April", "May", "June",
               "July", "August", "September", "October", "November", "December"]
            : ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
               "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    }

    /// Domingo primero.
    static var calendarWeekdaysShort: [String] {
        isEnglish
            ? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            : ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
    }
}
