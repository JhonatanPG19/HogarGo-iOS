import SwiftUI

/// Hoja "Nueva Factura": nombre, monto y fecha de vencimiento (hoy por defecto).
struct AddBillSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let householdId: String

    @State private var title = ""
    @State private var amountText = ""
    @State private var dueDate = Date()
    @State private var titleError: String?
    @State private var amountError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HogarTextField(
                        label: L10n.calendarBillNameLabel,
                        placeholder: L10n.calendarBillNameHint,
                        text: $title,
                        error: titleError
                    )
                    AmountField(label: L10n.calendarBillAmountLabel, text: $amountText, error: amountError)

                    DatePicker(
                        L10n.calendarBillDueDateLabel,
                        selection: $dueDate,
                        displayedComponents: .date
                    )
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(HogarGoColors.primaryText)

                    HogarPrimaryButton(title: L10n.financeAddButton, action: save)
                        .padding(.top, 6)
                }
                .padding(20)
            }
            .background(HogarGoColors.background)
            .navigationTitle(L10n.calendarAddBill)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.cancel) { dismiss() }
                        .foregroundStyle(HogarGoColors.secondaryText)
                }
            }
        }
    }

    private func save() {
        titleError = nil
        amountError = nil
        do {
            try appState.calendarRepository.addBill(
                householdId: householdId,
                title: title,
                amount: FinanceFormat.parseAmount(amountText),
                dueDateISO: ISODay.string(from: dueDate)
            )
            dismiss()
        } catch CalendarError.emptyTitle {
            titleError = L10n.financeErrorEmptyTitle
        } catch CalendarError.invalidAmount {
            amountError = L10n.financeErrorInvalidAmount
        } catch {
            appState.showToast(L10n.financeErrorInvalidAmount)
        }
    }
}

/// Hoja "Nuevo Evento": título, fecha (día seleccionado por defecto) y hora (10:00 por defecto).
struct AddEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let householdId: String
    let initialDate: Date
    /// Se llama con la fecha ISO del evento creado para que el calendario salte a ese día.
    let onCreated: (String) -> Void

    @State private var title = ""
    @State private var date: Date
    @State private var time: Date

    init(householdId: String, initialDate: Date, onCreated: @escaping (String) -> Void) {
        self.householdId = householdId
        self.initialDate = initialDate
        self.onCreated = onCreated
        _date = State(initialValue: initialDate)
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 10
        comps.minute = 0
        _time = State(initialValue: Calendar.current.date(from: comps) ?? Date())
    }

    private var canCreate: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HogarTextField(
                        label: L10n.calendarEventNameLabel,
                        placeholder: L10n.calendarEventNameHint,
                        text: $title
                    )

                    DatePicker(
                        L10n.calendarEventDateLabel,
                        selection: $date,
                        displayedComponents: .date
                    )
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(HogarGoColors.primaryText)

                    DatePicker(
                        L10n.calendarEventTimeLabel,
                        selection: $time,
                        displayedComponents: .hourAndMinute
                    )
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(HogarGoColors.primaryText)

                    HogarPrimaryButton(title: L10n.calendarEventCreate, isEnabled: canCreate, action: save)
                        .padding(.top, 6)
                }
                .padding(20)
            }
            .background(HogarGoColors.background)
            .navigationTitle(L10n.calendarAddEvent)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.cancel) { dismiss() }
                        .foregroundStyle(HogarGoColors.secondaryText)
                }
            }
        }
    }

    private func save() {
        let dateISO = ISODay.string(from: date)
        do {
            try appState.calendarRepository.addEvent(
                householdId: householdId,
                title: title,
                dateISO: dateISO,
                timeLabel: Self.timeLabel(from: time)
            )
            onCreated(dateISO)
            dismiss()
        } catch {
            appState.showToast(L10n.financeErrorInvalidAmount)
        }
    }

    /// "HH:mm" en 24 horas.
    private static func timeLabel(from date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "HH:mm"
        return df.string(from: date)
    }
}
