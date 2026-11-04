import SwiftData
import SwiftUI

/// Pantalla de Mascota: envoltorio que resuelve el hogar activo.
struct PetView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if let householdId = appState.householdId {
            PetContent(householdId: householdId)
                .id(householdId)
        } else {
            Color.clear
        }
    }
}

private struct PetContent: View {
    @Environment(AppState.self) private var appState

    let householdId: String

    @Query private var states: [PetState]
    @Query private var wardrobe: [WardrobeItem]
    @Query private var completedTasks: [HouseholdTask]

    init(householdId: String) {
        self.householdId = householdId
        _states = Query(filter: #Predicate<PetState> { $0.householdId == householdId })
        _wardrobe = Query(filter: #Predicate<WardrobeItem> { $0.householdId == householdId })
        _completedTasks = Query(
            filter: #Predicate<HouseholdTask> { $0.householdId == householdId && $0.completed }
        )
    }

    private var state: PetState? { states.first }
    private var level: Int { state?.level ?? 1 }
    private var happiness: Double { state?.happiness ?? PetRules.initialStat }
    private var satiety: Double { state?.satiety ?? PetRules.initialStat }

    private func item(_ id: String) -> WardrobeItem? { wardrobe.first { $0.itemId == id } }
    private var equippedIds: Set<String> { Set(wardrobe.filter(\.equipped).map(\.itemId)) }

    /// Monedas = ganadas − gastadas (nunca negativo).
    private var coins: Int {
        let earned = completedTasks.reduce(0) { $0 + $1.coinReward }
        let spent = wardrobe.filter(\.owned).reduce(0) { $0 + (WardrobeCatalog.entry(for: $1.itemId)?.price ?? 0) }
        return max(0, earned - spent)
    }

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
        .onAppear { appState.petRepository.refreshOnOpen(householdId: householdId) }
    }

    // MARK: - Escenario

    private func stageCard(scrollTo proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 14) {
            ZoriAvatarView(equippedIds: equippedIds, size: 200)

            wearingText

            HStack(spacing: 10) {
                careButton(L10n.petFeed, fill: HogarGoColors.brandOrangeDeep, text: .white) {
                    appState.petRepository.care(.feed, householdId: householdId)
                }
                careButton(L10n.petPlay, fill: HogarGoColors.brandOrange, text: HogarGoColors.primaryText) {
                    appState.petRepository.care(.play, householdId: householdId)
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
            let now = Int64(context.date.timeIntervalSince1970 * 1000)
            let feed = PetRules.cooldownRemaining(last: state?.lastFeedAt ?? 0, now: now)
            let play = PetRules.cooldownRemaining(last: state?.lastPlayAt ?? 0, now: now)

            if let text = cooldownText(feed: feed, play: play) {
                Text(text)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }
        }
    }

    private func cooldownText(feed: Int64, play: Int64) -> String? {
        switch (feed > 0, play > 0) {
        case (false, false):
            return nil
        case (true, true):
            return L10n.petCooldownAvailableIn(PetRules.minutesLabel(forRemaining: max(feed, play)))
        case (true, false):
            return L10n.petFeed + ": " + L10n.petCooldownAvailableIn(PetRules.minutesLabel(forRemaining: feed))
        case (false, true):
            return L10n.petPlay + ": " + L10n.petCooldownAvailableIn(PetRules.minutesLabel(forRemaining: play))
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
                Text("\(Int(value * 100))%")
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
                        onBuy: { appState.petRepository.buy(itemId: entry.id, householdId: householdId) },
                        onToggle: { appState.petRepository.toggleEquipped(itemId: entry.id, householdId: householdId) }
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
