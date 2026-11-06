import SwiftUI

/// Tarjeta de Inicio con la meta de ahorro real más antigua del hogar.
/// Si el hogar aún no tiene metas, no se muestra.
/// Recibe el `FinanceViewModel` ya creado por Inicio (que lo inicia en `onAppear`).
struct HomeGoalCard: View {
    let viewModel: FinanceViewModel

    var body: some View {
        if let goal = viewModel.goals.first {
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
/// Recibe el `PetViewModel` ya creado por Inicio (su `start()` crea el estado y aplica el decaimiento).
struct HomeZoriCard: View {
    let viewModel: PetViewModel

    var body: some View {
        VStack(spacing: 12) {
            ZoriAvatarView(equippedIds: viewModel.equippedIds, size: 150)
                .padding(.top, 8)

            HStack(spacing: 8) {
                Text("Zori")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                Text(L10n.petLevel(viewModel.level))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.brandOrangeDeep)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(HogarGoColors.brandOrangeContainer)
                    .clipShape(Capsule())
            }

            HStack(spacing: 16) {
                miniStat(L10n.petHappiness, viewModel.happiness)
                miniStat(L10n.petSatiety, viewModel.satiety)
            }
        }
        .frame(maxWidth: .infinity)
        .financeCard(padding: 16)
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
