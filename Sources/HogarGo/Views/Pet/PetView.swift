import SwiftData
import SwiftUI

/// Pantalla de Mascota: envoltorio que resuelve el hogar activo.
struct PetView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if let householdId = appState.householdId {
            PetContent(householdId: householdId, repository: appState.petRepository)
                .id(householdId)
        } else {
            Color.clear
        }
    }
}

private struct PetContent: View {
    // MVVM: el ViewModel guarda el estado de Zori y calcula nivel, monedas y cooldown.
    @State private var viewModel: PetViewModel

    init(householdId: String, repository: PetRepository) {
        _viewModel = State(initialValue: PetViewModel(householdId: householdId, repository: repository))
    }

    private var level: Int { viewModel.level }
    private var happiness: Double { viewModel.happiness }
    private var satiety: Double { viewModel.satiety }
    private var coins: Int { viewModel.coins }
    private var equippedIds: Set<String> { viewModel.equippedIds }
    private func item(_ id: String) -> WardrobeItem? { viewModel.item(id) }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    stageCard(scrollTo: proxy)
                    statusCard
                    wardrobeCard.id("wardrobe")
                    tipCard
                    Spacer(minLength: 28)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
        .background(HogarGoColors.background)
        .onAppear { viewModel.start() }
    }

    // MARK: - Escenario

    private func stageCard(scrollTo proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 14) {
            ZoriAvatarView(equippedIds: equippedIds, size: 200)

            wearingText

            HStack(spacing: 10) {
                careButton(L10n.petFeed, fill: HogarGoColors.brandOrangeDeep, text: .white) {
                    viewModel.feed()
                }
                careButton(L10n.petPlay, fill: HogarGoColors.brandOrange, text: HogarGoColors.primaryText) {
                    viewModel.play()
                }
                Button {
                    withAnimation { proxy.scrollTo("wardrobe", anchor: .top) }
                } label: {
                    Text(L10n.petDecorate)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(HogarGoColors.brandOrangeDeep)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .overlay(Capsule().stroke(HogarGoColors.brandOrangeDeep, lineWidth: 1.5))
                }
                .buttonStyle(.plain)
            }

            cooldownNotice
        }
        .frame(maxWidth: .infinity)
        .financeCard()
    }

    private var wearingText: some View {
        let worn = WardrobeCatalog.items.filter { equippedIds.contains($0.id) }
        return VStack(spacing: 4) {
            if worn.isEmpty {
                Text(L10n.petWearingNothing)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
            } else {
                Text(L10n.petWearing + " " + worn.map(\.emoji).joined())
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }
        }
    }

    private func careButton(_ title: String, fill: Color, text: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(fill)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    /// El contador baja solo (se refresca cada 30 s) y el aviso desaparece al terminar el cooldown.
    private var cooldownNotice: some View {
        TimelineView(.periodic(from: .now, by: 30)) { context in
            if let text = viewModel.cooldownText(now: context.date) {
                Text(text)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }
        }
    }

    // MARK: - Estado

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(L10n.petStatusTitle)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                Spacer()
                Text(L10n.petLevel(level))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.brandOrangeDeep)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(HogarGoColors.brandOrangeContainer)
                    .clipShape(Capsule())
            }

            statBar(label: L10n.petHappiness, value: happiness, color: HogarGoColors.brandOrange)
            statBar(label: L10n.petSatiety, value: satiety, color: HogarGoColors.brandOrangeDeep)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .financeCard()
    }

    private func statBar(label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(HogarGoColors.primaryText)
                Spacer()
                Text("\(Int((value * 100).rounded()))%")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(HogarGoColors.surfaceContainerHigh.opacity(0.6))
                    Capsule().fill(color).frame(width: proxy.size.width * min(max(value, 0), 1))
                }
            }
            .frame(height: 10)
        }
    }

    // MARK: - Armario

    private var wardrobeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.petWardrobeTitle)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                Spacer()
                Text(L10n.petCoinsBalance(coins))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.brandOrangeDeep)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(HogarGoColors.brandOrangeContainer)
                    .clipShape(Capsule())
            }

            Text(L10n.petWardrobeSubtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(HogarGoColors.secondaryText)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach(WardrobeCatalog.items) { entry in
                    WardrobeCard(
                        entry: entry,
                        level: level,
                        coins: coins,
                        owned: item(entry.id)?.owned ?? false,
                        equipped: item(entry.id)?.equipped ?? false,
                        onBuy: { viewModel.buy(entry.id) },
                        onToggle: { viewModel.toggleEquipped(entry.id) }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .financeCard()
    }

    // MARK: - Consejo

    private var tipCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.petTipTitle)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(L10n.petTipSubtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(HogarGoColors.brandOrangeDeep)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
