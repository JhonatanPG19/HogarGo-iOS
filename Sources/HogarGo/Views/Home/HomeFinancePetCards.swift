import SwiftData
import SwiftUI

/// Tarjeta de Inicio con la meta de ahorro real más antigua del hogar.
/// Si el hogar aún no tiene metas, no se muestra.
struct HomeGoalCard: View {
    @Query private var goals: [SavingsGoal]

    init(householdId: String) {
        _goals = Query(
            filter: #Predicate<SavingsGoal> { $0.householdId == householdId },
            sort: [SortDescriptor(\SavingsGoal.createdAt, order: .forward)]
        )
    }

    var body: some View {
        if let goal = goals.first {
            VStack(spacing: 12) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "banknote")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(HogarGoColors.primaryText)
                        Text(goal.title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(HogarGoColors.primaryText)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text("\(Int((goal.progress * 100).rounded()))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(HogarGoColors.primaryText)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(HogarGoColors.surfaceContainer)
                        Capsule()
                            .fill(HogarGoColors.brandOrange)
                            .frame(width: proxy.size.width * goal.progress)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text(FinanceFormat.money(goal.currentAmount))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(HogarGoColors.secondaryText)
                    Spacer()
                    Text(FinanceFormat.money(goal.targetAmount))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(HogarGoColors.secondaryText)
                }
            }
            .financeCard(radius: 20, padding: 16)
        }
    }
}

/// Tarjeta de Inicio con Zori real: objetos puestos, nivel y estado.
struct HomeZoriCard: View {
    @Environment(AppState.self) private var appState

    let householdId: String

    @Query private var states: [PetState]
    @Query private var wardrobe: [WardrobeItem]

    init(householdId: String) {
        self.householdId = householdId
        _states = Query(filter: #Predicate<PetState> { $0.householdId == householdId })
        _wardrobe = Query(filter: #Predicate<WardrobeItem> { $0.householdId == householdId })
    }

    private var state: PetState? { states.first }
    private var equippedIds: Set<String> { Set(wardrobe.filter(\.equipped).map(\.itemId)) }

    var body: some View {
        VStack(spacing: 12) {
            ZoriAvatarView(equippedIds: equippedIds, size: 150)
                .padding(.top, 8)

            HStack(spacing: 8) {
                Text("Zori")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                Text(L10n.petLevel(state?.level ?? 1))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.brandOrangeDeep)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(HogarGoColors.brandOrangeContainer)
                    .clipShape(Capsule())
            }

            HStack(spacing: 16) {
                miniStat(L10n.petHappiness, state?.happiness ?? PetRules.initialStat)
                miniStat(L10n.petSatiety, state?.satiety ?? PetRules.initialStat)
            }
        }
        .frame(maxWidth: .infinity)
        .financeCard(padding: 16)
        // Crea el estado de Zori y aplica el decaimiento también al abrir Inicio.
        .onAppear { appState.petRepository.refreshOnOpen(householdId: householdId) }
    }

    private func miniStat(_ label: String, _ value: Double) -> some View {
        VStack(spacing: 4) {
            Text("\(label) \(Int((value * 100).rounded()))%")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(HogarGoColors.secondaryText)
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(HogarGoColors.surfaceContainerHigh.opacity(0.6))
                    Capsule()
                        .fill(HogarGoColors.brandOrange)
                        .frame(width: proxy.size.width * min(max(value, 0), 1))
                }
            }
            .frame(height: 6)
        }
        .frame(maxWidth: .infinity)
    }
}
