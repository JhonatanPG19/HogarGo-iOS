import SwiftData
import SwiftUI

/// Pantalla de Calendario: envoltorio que resuelve el hogar activo.
struct CalendarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if let householdId = appState.householdId {
            CalendarContent(householdId: householdId)
                .id(householdId)
        } else {
            Color.clear
        }
    }
}

private enum CalendarColors {
    static let event = Color(red: 0x3B / 255, green: 0x82 / 255, blue: 0xC4 / 255)
    static let task = Color(red: 0x4C / 255, green: 0x9A / 255, blue: 0x5F / 255)
}

private struct CalendarContent: View {
    @Environment(AppState.self) private var appState

    let householdId: String

    @Query private var bills: [Bill]
    @Query private var events: [CalendarEvent]
    @Query private var completedTasks: [HouseholdTask]

    /// Meses de desplazamiento respecto al mes actual y día seleccionado (sobreviven a la recreación de la escena).
    @SceneStorage("calendar.monthOffset") private var monthOffset = 0
    @SceneStorage("calendar.selectedDay") private var selectedISO = ""

    @State private var showAddBill = false
    @State private var showAddEvent = false

    init(householdId: String) {
        self.householdId = householdId
        _bills = Query(
            filter: #Predicate<Bill> { $0.householdId == householdId },
            sort: [SortDescriptor(\Bill.dueDateISO, order: .forward)]
        )
        _events = Query(filter: #Predicate<CalendarEvent> { $0.householdId == householdId })
        _completedTasks = Query(
            filter: #Predicate<HouseholdTask> { $0.householdId == householdId && $0.completed }
        )
    }

    private var todayISO: String { ISODay.today() }
    private var selectedDayISO: String { selectedISO.isEmpty ? todayISO : selectedISO }
    private var selectedDate: Date { ISODay.date(from: selectedDayISO) ?? Date() }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                header
                monthCard
                dayDetailCard
                upcomingCard
                billsCard
                Spacer(minLength: 28)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(HogarGoColors.background)
        .sheet(isPresented: $showAddBill) {
            AddBillSheet(householdId: householdId)
        }
        .sheet(isPresented: $showAddEvent) {
            AddEventSheet(householdId: householdId, initialDate: selectedDate) { dateISO in
                // Al crear un evento, la selección salta a su fecha (y al mes que la contiene).
                selectedISO = dateISO
                if let date = ISODay.date(from: dateISO) {
                    monthOffset = Self.monthsBetweenNow(and: date)
                }
            }
        }
    }

    private static func monthsBetweenNow(and date: Date) -> Int {
        let cal = Calendar(identifier: .gregorian)
        let now = cal.dateComponents([.year, .month], from: Date())
        let target = cal.dateComponents([.year, .month], from: date)
        return ((target.year ?? 0) - (now.year ?? 0)) * 12 + ((target.month ?? 0) - (now.month ?? 0))
    }

    // MARK: - Encabezado

    private var header: some View {
        VStack(spacing: 4) {
            Text(L10n.calendarTitle)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)
            Text(L10n.calendarSubtitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(HogarGoColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Mes

    private var monthCard: some View {
        let start = CalendarMath.monthStart(offset: monthOffset)
        let cells = CalendarMath.cells(monthStart: start)
        let title = L10n.calendarMonthYear(
            L10n.calendarMonths[CalendarMath.monthIndex(of: start)],
            CalendarMath.year(of: start)
        )

        return VStack(spacing: 14) {
            HStack {
                Button {
                    monthOffset -= 1
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .bold))
                        .frame(width: 36, height: 36)
                }
                .accessibilityLabel(L10n.calendarPrevMonth)

                Spacer()
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()

                Button {
                    monthOffset += 1
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .bold))
                        .frame(width: 36, height: 36)
                }
                .accessibilityLabel(L10n.calendarNextMonth)
            }
            .buttonStyle(.plain)
            .foregroundStyle(HogarGoColors.primaryText)

            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(L10n.calendarWeekdaysShort.enumerated()), id: \.offset) { _, name in
                    Text(name)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(HogarGoColors.secondaryText)
                }

                ForEach(Array(cells.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(date)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }

            legend
        }
        .financeCard()
    }

    private func dayCell(_ date: Date) -> some View {
        let iso = ISODay.string(from: date)
        let isToday = iso == todayISO
        let isSelected = iso == selectedDayISO
        let day = Calendar(identifier: .gregorian).component(.day, from: date)

        return Button {
            selectedISO = iso
        } label: {
            VStack(spacing: 3) {
                Text("\(day)")
                    .font(.system(size: 14, weight: isToday ? .bold : .medium, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                HStack(spacing: 3) {
                    ForEach(Array(dots(for: iso).enumerated()), id: \.offset) { _, color in
                        Circle().fill(color).frame(width: 5, height: 5)
                    }
                }
                .frame(height: 5)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(isSelected ? HogarGoColors.brandOrangeContainer : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isToday ? HogarGoColors.brandOrangeDeep : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    /// Hasta 3 puntos, en este orden: factura, evento, tarea completada.
    private func dots(for iso: String) -> [Color] {
        var colors: [Color] = []

        let dueBills = bills.filter { $0.dueDateISO == iso && !$0.paid }
        if !dueBills.isEmpty {
            let overdue = dueBills.contains { $0.dueDateISO <= todayISO }
            colors.append(overdue ? HogarGoColors.alertRed : HogarGoColors.brandOrangeDeep)
        }
        if events.contains(where: { $0.dateISO == iso }) {
            colors.append(CalendarColors.event)
        }
        if completedTasks.contains(where: { $0.completedDate == iso }) {
            colors.append(CalendarColors.task)
        }
        return colors
    }

    private var legend: some View {
        HStack(spacing: 16) {
            legendItem(CalendarColors.event, L10n.calendarLegendEvents)
            legendItem(HogarGoColors.brandOrangeDeep, L10n.calendarLegendBills)
            legendItem(CalendarColors.task, L10n.calendarLegendTasks)
        }
    }

    private func legendItem(_ color: Color, _ text: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(HogarGoColors.secondaryText)
        }
    }

    // MARK: - Detalle del día

    private var dayDetailCard: some View {
        let iso = selectedDayISO
        let dayEvents = events
            .filter { $0.dateISO == iso }
            .sorted { ($0.timeLabel ?? "") < ($1.timeLabel ?? "") }
        let dayBills = bills.filter { $0.dueDateISO == iso }
        // TODO(integración tareas): hoy solo se leen las tareas completadas; no hay eventos
        // automáticos tipo "próxima tarea".
        let dayTasks = completedTasks.filter { $0.completedDate == iso }
        let isEmpty = dayEvents.isEmpty && dayBills.isEmpty && dayTasks.isEmpty

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(Self.longDate(selectedDate))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                Spacer()
                Button {
                    showAddEvent = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(HogarGoColors.brandOrangeDeep)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.calendarAddEvent)
            }

            if isEmpty {
                Text(L10n.calendarDayEmpty)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }

            if !dayEvents.isEmpty {
                sectionTitle(L10n.calendarDayEvents)
                ForEach(dayEvents) { event in
                    eventRow(event, subtitle: event.timeLabel)
                }
            }

            if !dayBills.isEmpty {
                sectionTitle(L10n.calendarDayBills)
                ForEach(dayBills) { bill in
                    billRow(bill, showDate: false)
                }
            }

            if !dayTasks.isEmpty {
                sectionTitle(L10n.calendarDayTasks)
                ForEach(dayTasks) { task in
                    Text("• " + task.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(HogarGoColors.primaryText)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(HogarGoColors.surfaceContainer)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    /// Fecha larga localizada (ej. "Martes 4 de noviembre") con la inicial en mayúscula.
    private static func longDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: L10n.isEnglish ? "en" : "es")
        df.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
        let text = df.string(from: date)
        return text.prefix(1).uppercased() + text.dropFirst()
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(HogarGoColors.brandOrangeDeep)
            .padding(.top, 4)
    }

    // MARK: - Próximos eventos

    private var upcomingCard: some View {
        let upcoming = events
            .filter { $0.dateISO >= todayISO }
            .sorted {
                if $0.dateISO != $1.dateISO { return $0.dateISO < $1.dateISO }
                return ($0.timeLabel ?? "") < ($1.timeLabel ?? "")
            }

        return VStack(alignment: .leading, spacing: 12) {
            Text(L10n.calendarUpcoming)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)

            if upcoming.isEmpty {
                Text(L10n.calendarEventsEmpty)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
            } else {
                ForEach(upcoming) { event in
                    let subtitle = ISODay.short(event.dateISO) + (event.timeLabel.map { " • " + $0 } ?? "")
                    eventRow(event, subtitle: subtitle)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .financeCard()
    }

    private func eventRow(_ event: CalendarEvent, subtitle: String?) -> some View {
        HStack(spacing: 10) {
            checkbox(checked: event.done) {
                try? appState.calendarRepository.toggleEventDone(event)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                    .strikethrough(event.done)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(HogarGoColors.secondaryText)
                }
            }
            Spacer(minLength: 8)
            deleteButton(label: L10n.calendarDeleteEvent) {
                try? appState.calendarRepository.deleteEvent(event)
            }
        }
    }

    // MARK: - Facturas

    private var billsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.calendarBillsDue)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                Spacer()
                Button {
                    showAddBill = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(HogarGoColors.brandOrangeDeep)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.calendarAddBill)
            }

            if bills.isEmpty {
                Text(L10n.calendarBillsEmpty)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
            } else {
                ForEach(bills) { bill in
                    billRow(bill, showDate: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .financeCard()
    }

    private func billRow(_ bill: Bill, showDate: Bool) -> some View {
        // "¡Vence Hoy!" solo el día del vencimiento; después de esa fecha dice "Vencida".
        let dueToday = !bill.paid && bill.dueDateISO == todayISO
        let overdue = !bill.paid && bill.dueDateISO < todayISO

        return HStack(spacing: 10) {
            checkbox(checked: bill.paid) {
                try? appState.calendarRepository.toggleBillPaid(bill)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(bill.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                    .strikethrough(bill.paid)
                if dueToday || overdue {
                    Text(dueToday ? L10n.calendarDueToday : L10n.calendarOverdue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(HogarGoColors.alertRed)
                } else if showDate {
                    Text(ISODay.short(bill.dueDateISO))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(HogarGoColors.secondaryText)
                }
            }
            Spacer(minLength: 8)
            Text(FinanceFormat.money(bill.amount))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)
            deleteButton(label: L10n.calendarDeleteBill) {
                try? appState.calendarRepository.deleteBill(bill)
            }
        }
    }

    // MARK: - Componentes

    private func checkbox(checked: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: checked ? "checkmark.square.fill" : "square")
                .font(.system(size: 22))
                .foregroundStyle(checked ? HogarGoColors.brandOrangeDeep : HogarGoColors.outlineVariant)
        }
        .buttonStyle(.plain)
    }

    private func deleteButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "trash")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(HogarGoColors.alertRed)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
