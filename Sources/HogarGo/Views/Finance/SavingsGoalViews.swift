import SwiftUI

/// Frasco que se llena de abajo hacia arriba según el progreso (0...1).
struct GoalJar: View {
    let progress: Double

    private let bodyWidth: CGFloat = 80
    private let bodyHeight: CGFloat = 96

    var body: some View {
        VStack(spacing: 0) {
            // Tapa
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(HogarGoColors.outlineVariant)
                .frame(width: 64, height: 12)

            // Cuerpo con relleno
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(HogarGoColors.surfaceContainerHigh.opacity(0.6))

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [HogarGoColors.brandOrange, HogarGoColors.brandOrangeDeep],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: bodyHeight * min(max(progress, 0), 1))
            }
            .frame(width: bodyWidth, height: bodyHeight)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
            )
        }
    }
}

/// Tarjeta de una meta de ahorro.
struct SavingsGoalCard: View {
    let goal: SavingsGoal
    var width: CGFloat? = nil
    let onContribute: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(goal.title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)
                .lineLimit(1)

            Text(L10n.financeSavingsProgress(
                FinanceFormat.money(goal.currentAmount),
                FinanceFormat.money(goal.targetAmount)
            ))
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(HogarGoColors.secondaryText)

            GoalJar(progress: goal.progress)
                .padding(.vertical, 8)

            HStack(spacing: 10) {
                Button(action: onContribute) {
                    Text(L10n.financeGoalContributeButton)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 10)
                        .background(HogarGoColors.brandOrangeDeep)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(HogarGoColors.alertRed)
                        .frame(width: 40, height: 40)
                        .background(HogarGoColors.surfaceContainerLow)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.financeGoalDeleteButton)
            }
        }
        .frame(maxWidth: width == nil ? .infinity : nil)
        .frame(width: width)
        .financeCard()
    }
}

/// Hoja "Crear Meta de Ahorro".
struct CreateGoalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let householdId: String

    @State private var title = ""
    @State private var targetText = ""
    @State private var titleError: String?
    @State private var targetError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HogarTextField(
                        label: L10n.financeGoalNameLabel,
                        placeholder: L10n.financeGoalNameHint,
                        text: $title,
                        error: titleError
                    )
                    AmountField(label: L10n.financeGoalTargetLabel, text: $targetText, error: targetError)
                    HogarPrimaryButton(title: L10n.financeGoalCreateButton, action: save)
                        .padding(.top, 6)
                }
                .padding(20)
            }
            .background(HogarGoColors.background)
            .navigationTitle(L10n.financeGoalCreateTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.financeCancelButton) { dismiss() }
                        .foregroundStyle(HogarGoColors.secondaryText)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        titleError = nil
        targetError = nil
        do {
            try appState.financeRepository.addGoal(
                householdId: householdId,
                title: title,
                targetAmount: FinanceFormat.parseAmount(targetText)
            )
            dismiss()
        } catch FinanceError.emptyTitle {
            titleError = L10n.financeErrorEmptyTitle
        } catch FinanceError.invalidAmount {
            targetError = L10n.financeErrorInvalidAmount
        } catch {
            appState.showToast(L10n.financeErrorInvalidAmount)
        }
    }
}

/// Hoja "Aportar a <meta>".
struct ContributeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let goal: SavingsGoal

    @State private var amountText = ""
    @State private var amountError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    AmountField(label: L10n.financeGoalContributeAmountLabel, text: $amountText, error: amountError)
                    HogarPrimaryButton(title: L10n.financeGoalContributeButton, action: save)
                        .padding(.top, 6)
                }
                .padding(20)
            }
            .background(HogarGoColors.background)
            .navigationTitle(L10n.financeGoalContributeTo(goal.title))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.financeCancelButton) { dismiss() }
                        .foregroundStyle(HogarGoColors.secondaryText)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func save() {
        amountError = nil
        do {
            try appState.financeRepository.contribute(to: goal, amount: FinanceFormat.parseAmount(amountText))
            dismiss()
        } catch {
            amountError = L10n.financeErrorInvalidAmount
        }
    }
}
