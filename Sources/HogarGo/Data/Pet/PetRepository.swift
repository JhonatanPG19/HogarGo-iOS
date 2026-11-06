import Foundation
import SwiftData

enum PetCare {
    case feed
    case play
}

/// Cuidado de Zori y ropero. Monedas = tareas completadas − precio de lo comprado.
@MainActor
final class PetRepository {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Estado

    /// Al abrir la pantalla: crea el estado y el ropero si faltan y aplica el decaimiento.
    func refreshOnOpen(householdId: String, now: Int64 = Clock.nowMillis()) {
        let state = ensureState(householdId: householdId, now: now)
        ensureWardrobe(householdId: householdId)
        PetRules.applyDecay(to: state, now: now)
        try? saveContext()
    }

    /// Alimentar o jugar. Devuelve `false` si el cooldown de esa acción sigue activo.
    @discardableResult
    func care(_ kind: PetCare, householdId: String, now: Int64 = Clock.nowMillis()) -> Bool {
        let state = ensureState(householdId: householdId, now: now)
        PetRules.applyDecay(to: state, now: now)

        let last = kind == .feed ? state.lastFeedAt : state.lastPlayAt
        guard PetRules.cooldownRemaining(last: last, now: now) == 0 else {
            try? saveContext()
            return false
        }

        switch kind {
        case .feed:
            state.satiety = min(1, state.satiety + PetRules.careGain)
            state.lastFeedAt = now
        case .play:
            state.happiness = min(1, state.happiness + PetRules.careGain)
            state.lastPlayAt = now
        }
        state.careActions += 1
        try? saveContext()
        return true
    }

    // MARK: - Monedas y ropero

    /// Suma de `coinReward` de las tareas completadas del hogar.
    func earnedCoins(householdId: String) -> Int {
        let descriptor = FetchDescriptor<HouseholdTask>(
            predicate: #Predicate { $0.householdId == householdId && $0.completed }
        )
        let tasks = (try? context.fetch(descriptor)) ?? []
        return tasks.reduce(0) { $0 + $1.coinReward }
    }

    /// Saldo = ganadas − gastadas, nunca negativo. No se guarda: se calcula siempre.
    func coins(householdId: String) -> Int {
        let owned = wardrobe(householdId: householdId).filter(\.owned)
        let spent = owned.reduce(0) { $0 + (WardrobeCatalog.entry(for: $1.itemId)?.price ?? 0) }
        return max(0, earnedCoins(householdId: householdId) - spent)
    }

    func level(householdId: String) -> Int {
        state(householdId: householdId)?.level ?? 1
    }

    /// Compra un objeto. Falla si no existe, el nivel no alcanza, ya es tuyo o no hay monedas.
    @discardableResult
    func buy(itemId: String, householdId: String) -> Bool {
        guard let entry = WardrobeCatalog.entry(for: itemId) else { return false }
        ensureWardrobe(householdId: householdId)
        guard let item = wardrobeItem(householdId: householdId, itemId: itemId) else { return false }
        guard level(householdId: householdId) >= entry.unlockLevel,
              !item.owned,
              coins(householdId: householdId) >= entry.price else { return false }

        item.owned = true
        item.equipped = false
        try? saveContext()
        return true
    }

    /// Pone o quita un objeto ya comprado (se pueden llevar varios a la vez).
    @discardableResult
    func toggleEquipped(itemId: String, householdId: String) -> Bool {
        guard let entry = WardrobeCatalog.entry(for: itemId),
              let item = wardrobeItem(householdId: householdId, itemId: itemId),
              level(householdId: householdId) >= entry.unlockLevel,
              item.owned else { return false }

        item.equipped.toggle()
        try? saveContext()
        return true
    }

    // MARK: - Consultas

    func state(householdId: String) -> PetState? {
        var descriptor = FetchDescriptor<PetState>(predicate: #Predicate { $0.householdId == householdId })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    func wardrobe(householdId: String) -> [WardrobeItem] {
        let descriptor = FetchDescriptor<WardrobeItem>(predicate: #Predicate { $0.householdId == householdId })
        return (try? context.fetch(descriptor)) ?? []
    }

    private func wardrobeItem(householdId: String, itemId: String) -> WardrobeItem? {
        wardrobe(householdId: householdId).first { $0.itemId == itemId }
    }

    // MARK: - Altas

    /// Busca antes de insertar para que haya una sola fila por hogar.
    private func ensureState(householdId: String, now: Int64) -> PetState {
        if let existing = state(householdId: householdId) { return existing }
        let created = PetState(householdId: householdId, lastDecayAt: now)
        context.insert(created)
        return created
    }

    /// Siembra las filas faltantes del ropero (sin comprar ni puestas).
    private func ensureWardrobe(householdId: String) {
        let existing = Set(wardrobe(householdId: householdId).map(\.itemId))
        for entry in WardrobeCatalog.items where !existing.contains(entry.id) {
            context.insert(WardrobeItem(householdId: householdId, itemId: entry.id))
        }
    }

    private func saveContext() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw SaveFailure()
        }
    }

    private struct SaveFailure: Error {}
}
