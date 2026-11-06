import Foundation
import Observation

/// ViewModel de Mascota (MVVM). Mismas reglas que `FinanceViewModel`:
/// datos en propiedades `@Observable`, `reload()` tras cada acción y suscripción a `didSave`.
/// Las monedas dependen de las tareas completadas, que se completan en otra pantalla;
/// por eso la suscripción a `didSave` es imprescindible aquí.
@MainActor
@Observable
final class PetViewModel {
    // MARK: Estado que observa la vista

    private(set) var state: PetState?
    private(set) var wardrobe: [WardrobeItem] = []
    /// Suma de `coinReward` de las tareas completadas del hogar.
    private(set) var earnedCoins = 0

    // MARK: Dependencias

    let householdId: String
    @ObservationIgnored private let repository: PetRepository
    @ObservationIgnored private var observer: SaveObserver?

    init(householdId: String, repository: PetRepository) {
        self.householdId = householdId
        self.repository = repository
    }

    /// Al aparecer la pantalla: crea el estado y el armario si faltan, aplica el decaimiento
    /// y empieza a escuchar los guardados.
    func start() {
        repository.refreshOnOpen(householdId: householdId)
        if observer == nil {
            observer = SaveObserver(context: repository.context) { [weak self] in
                self?.reload()
            }
        }
        reload()
    }

    func reload() {
        state = repository.state(householdId: householdId)
        wardrobe = repository.wardrobe(householdId: householdId)
        earnedCoins = repository.earnedCoins(householdId: householdId)
    }

    // MARK: Estado derivado

    var level: Int { state?.level ?? 1 }
    var happiness: Double { state?.happiness ?? PetRules.initialStat }
    var satiety: Double { state?.satiety ?? PetRules.initialStat }

    func item(_ id: String) -> WardrobeItem? {
        wardrobe.first { $0.itemId == id }
    }

    var equippedIds: Set<String> {
        Set(wardrobe.filter(\.equipped).map(\.itemId))
    }

    /// Monedas = ganadas − gastadas (nunca negativo). No se guarda: se calcula siempre.
    var coins: Int {
        let spent = wardrobe
            .filter(\.owned)
            .reduce(0) { $0 + (WardrobeCatalog.entry(for: $1.itemId)?.price ?? 0) }
        return max(0, earnedCoins - spent)
    }

    /// Texto "Disponible en N min" para el cooldown de alimentar y jugar (`nil` si no hay espera).
    func cooldownText(now: Date) -> String? {
        let nowMillis = Int64(now.timeIntervalSince1970 * 1000)
        let feed = PetRules.cooldownRemaining(last: state?.lastFeedAt ?? 0, now: nowMillis)
        let play = PetRules.cooldownRemaining(last: state?.lastPlayAt ?? 0, now: nowMillis)

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

    // MARK: Acciones

    func feed() {
        repository.care(.feed, householdId: householdId)
        reload()
    }

    func play() {
        repository.care(.play, householdId: householdId)
        reload()
    }

    func buy(_ itemId: String) {
        repository.buy(itemId: itemId, householdId: householdId)
        reload()
    }

    func toggleEquipped(_ itemId: String) {
        repository.toggleEquipped(itemId: itemId, householdId: householdId)
        reload()
    }
}
