import SwiftData
import SwiftUI

/// Pantalla de Finanzas: envoltorio que resuelve el hogar activo.
struct FinanceView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if let householdId = appState.householdId {
            FinanceContent(householdId: householdId, repository: appState.financeRepository)
                .id(householdId)
        } else {
            Color.clear
        }
    }
}

private struct FinanceContent: View {
    @Environment(AppState.self) private var appState

    let householdId: String

    // MVVM: el ViewModel guarda los datos y calcula lo derivado; la vista solo los pinta.
    @State private var viewModel: FinanceViewModel

    @State private var showNewExpense = false
    @State private var showNewGoal = false
    @State private var goalToContribute: SavingsGoal?
    @State private var goalToDelete: SavingsGoal?

    init(householdId: String, repository: FinanceRepository) {
        self.householdId = householdId
        _viewModel = State(initialValue: FinanceViewModel(householdId: householdId, repository: repository))
    }

    private var expenses: [Expense] { viewModel.expenses }
    private var goals: [SavingsGoal] { viewModel.goals }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                header
                goalsSection
                monthCard
                breakdownCard
                recentCard
                Spacer(minLength: 28)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(HogarGoColors.background)
        .onAppear { viewModel.start() }
        .sheet(isPresented: $showNewExpense) {
            AddExpenseSheet(householdId: householdId)
        }
        .sheet(isPresented: $showNewGoal) {
            CreateGoalSheet(householdId: householdId)
        }
        .sheet(item: $goalToContribute) { goal in
            ContributeSheet(goal: goal)
        }
        .alert(
            L10n.financeGoalDeleteTitle,
            isPresented: Binding(
                get: { goalToDelete != nil },
                set: { if !$0 { goalToDelete = nil } }
            ),
            presenting: goalToDelete
        ) { goal in
            Button(L10n.financeGoalDeleteButton, role: .destructive) {
                viewModel.deleteGoal(goal)
                goalToDelete = nil
            }
            Button(L10n.financeCancelButton, role: .cancel) { goalToDelete = nil }
        } message: { goal in
            Text(L10n.financeGoalDeleteMessage(goal.title))
        }
    }

    // MARK: - Secciones

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.financeTitle)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)

            Text(L10n.financeSubtitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(HogarGoColors.secondaryText)

            Button {
                showNewExpense = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                    Text(L10n.financeNewExpense)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundStyle(HogarGoColors.primaryText)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.financeGoalsTitle)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                Spacer()
                if !goals.isEmpty {
                    Button {
                        showNewGoal = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                            Text(L10n.financeGoalNew)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(HogarGoColors.brandOrangeDeep)
                    }
                    .buttonStyle(.plain)
                }
            }

            if goals.isEmpty {
                VStack(spacing: 12) {
                    Text(L10n.financeGoalEmptyTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(HogarGoColors.secondaryText)
                        .multilineTextAlignment(.center)
                    Button {
                        showNewGoal = true
                    } label: {
                        Text(L10n.financeGoalEmptyAction)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 10)
                            .background(HogarGoColors.brandOrangeDeep)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .financeCard()
            } else if goals.count == 1, let goal = goals.first {
                SavingsGoalCard(
                    goal: goal,
                    onContribute: { goalToContribute = goal },
                    onDelete: { goalToDelete = goal }
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(goals) { goal in
                            SavingsGoalCard(
                                goal: goal,
                                width: 280,
                                onContribute: { goalToContribute = goal },
                                onDelete: { goalToDelete = goal }
                            )
                        }
                    }
                }
            }
        }
    }

    private var monthCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.financeThisMonth)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)

            HStack(spacing: 14) {
                metricTile(
                    icon: "chart.line.downtrend.xyaxis",
                    label: L10n.financeSpent,
                    value: FinanceFormat.money(viewModel.monthTotal)
                )
                metricTile(
                    icon: "divide",
                    label: L10n.financeAverage,
                    value: FinanceFormat.money(viewModel.monthAverage)
                )
            }
        }
        .financeCard(radius: 22, padding: 16)
    }

    private func metricTile(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(HogarGoColors.primaryText)
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(HogarGoColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var breakdownCard: some View {
        let rows = viewModel.breakdown
        return VStack(alignment: .leading, spacing: 14) {
            Text(L10n.financeBreakdown)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)

            VStack(spacing: 12) {
                ForEach(rows) { row in
                    VStack(spacing: 6) {
                        HStack {
                            Text(row.category.displayName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(HogarGoColors.primaryText)
                            Spacer()
                            Text(FinanceFormat.money(row.amount))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(HogarGoColors.secondaryText)
                        }
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(HogarGoColors.surfaceContainerHigh.opacity(0.6))
                                Capsule()
                                    .fill(row.category.color)
                                    .frame(width: proxy.size.width * row.fraction)
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .financeCard(radius: 22, padding: 16)
    }

    private var recentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.financeRecentExpenses)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)

            if expenses.isEmpty {
                Text(L10n.financeEmptyExpenses)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
            } else {
                VStack(spacing: 14) {
                    ForEach(expenses) { expense in
                        ExpenseRow(expense: expense) {
                            viewModel.deleteExpense(expense)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .financeCard(radius: 22, padding: 16)
    }
}

private struct ExpenseRow: View {
    let expense: Expense
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(expense.category.color)
                    .frame(width: 48, height: 48)
                Image(systemName: expense.category.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(expense.category.iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                    .lineLimit(1)
                Text(expense.category.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text("-" + FinanceFormat.money(expense.amount))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                Text(ISODay.short(expense.dateISO))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(HogarGoColors.alertRed)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.financeDeleteExpense)
        }
    }
}
