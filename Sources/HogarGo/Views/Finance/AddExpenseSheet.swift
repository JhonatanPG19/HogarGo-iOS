import SwiftUI

/// Hoja "Nuevo Gasto": monto, descripción, categoría y fecha.
struct AddExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let householdId: String

    @State private var amountText = ""
    @State private var title = ""
    @State private var category: ExpenseCategory = .groceries
    @State private var date = Date()
    @State private var titleError: String?
    @State private var amountError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    AmountField(label: L10n.financeExpenseAmountLabel, text: $amountText, error: amountError)

                    HogarTextField(
                        label: L10n.financeExpenseNameLabel,
                        placeholder: L10n.financeExpenseNameHint,
                        text: $title,
                        error: titleError
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.financeExpenseCategoryLabel)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(HogarGoColors.primaryText)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(ExpenseCategory.allCases) { item in
                                    categoryChip(item)
                                }
                            }
                        }
                    }

                    DatePicker(
                        L10n.financeExpenseDateLabel,
                        selection: $date,
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
            // El error desaparece en cuanto la persona vuelve a escribir en ese campo.
            .onChange(of: title) { titleError = nil }
            .onChange(of: amountText) { amountError = nil }
            .navigationTitle(L10n.financeNewExpense)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.financeCancelButton) { dismiss() }
                        .foregroundStyle(HogarGoColors.secondaryText)
                }
            }
        }
    }

    private func categoryChip(_ item: ExpenseCategory) -> some View {
        let selected = item == category
        return Button {
            category = item
        } label: {
            HStack(spacing: 6) {
                Image(systemName: item.iconName)
                    .font(.system(size: 13, weight: .semibold))
                Text(item.displayName)
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundStyle(selected ? Color.white : HogarGoColors.primaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(selected ? HogarGoColors.brandOrangeDeep : HogarGoColors.surfaceContainerLow)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(HogarGoColors.borderSubtle, lineWidth: selected ? 0 : 1))
        }
        .buttonStyle(.plain)
    }

    private func save() {
        // Se validan los dos campos a la vez para mostrar todos los errores juntos.
        let amount = FinanceFormat.parseAmount(amountText)
        titleError = title.trimmed.isEmpty ? L10n.financeErrorEmptyTitle : nil
        amountError = (amount ?? 0) > 0 ? nil : L10n.financeErrorInvalidAmount
        guard titleError == nil, amountError == nil else { return }

        do {
            try appState.financeRepository.addExpense(
                householdId: householdId,
                title: title,
                category: category,
                amount: amount,
                dateISO: ISODay.string(from: date)
            )
            dismiss()
        } catch {
            appState.showToast(L10n.financeErrorInvalidAmount)
        }
    }
}
