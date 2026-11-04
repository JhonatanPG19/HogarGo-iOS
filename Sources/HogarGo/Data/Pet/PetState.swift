import Foundation
import SwiftData

/// Estado de Zori. Una fila por hogar (la unicidad la garantiza `PetRepository`).
@Model
final class PetState {
    var householdId: String
    /// 0...1
    var happiness: Double
    /// 0...1
    var satiety: Double
    var careActions: Int
    var lastFeedAt: Int64
    var lastPlayAt: Int64
    /// Último instante hasta el que ya se aplicó el decaimiento.
    var lastDecayAt: Int64

    init(
        householdId: String,
        happiness: Double = PetRules.initialStat,
        satiety: Double = PetRules.initialStat,
        careActions: Int = 0,
        lastFeedAt: Int64 = 0,
        lastPlayAt: Int64 = 0,
        lastDecayAt: Int64 = Clock.nowMillis()
    ) {
        self.householdId = householdId
        self.happiness = happiness
        self.satiety = satiety
        self.careActions = careActions
        self.lastFeedAt = lastFeedAt
        self.lastPlayAt = lastPlayAt
        self.lastDecayAt = lastDecayAt
    }

    var level: Int { PetRules.level(careActions: careActions) }
}

/// Reglas de la mascota (idénticas a Android).
enum PetRules {
    /// Cada 2 horas baja un escalón.
    static let decayInterval: Int64 = 7_200_000
    static let decayAmount: Double = 0.05
    static let careGain: Double = 0.15
    /// 15 minutos entre cuidados del mismo tipo.
    static let cooldown: Int64 = 900_000
    static let actionsPerLevel = 5
    static let initialStat: Double = 0.5

    static func level(careActions: Int) -> Int {
        1 + careActions / actionsPerLevel
    }

    /// Resta `decayAmount` por cada intervalo completo transcurrido y avanza `lastDecayAt`
    /// por múltiplos exactos (no a `now`) para no perder el resto del intervalo.
    static func applyDecay(to state: PetState, now: Int64) {
        let chunks = (now - state.lastDecayAt) / decayInterval
        guard chunks > 0 else { return }
        let drop = decayAmount * Double(chunks)
        state.happiness = max(0, state.happiness - drop)
        state.satiety = max(0, state.satiety - drop)
        state.lastDecayAt += chunks * decayInterval
    }

    static func cooldownRemaining(last: Int64, now: Int64) -> Int64 {
        max(0, cooldown - (now - last))
    }

    /// Minutos mostrados en "Disponible en N min" (redondeo hacia arriba).
    static func minutesLabel(forRemaining remaining: Int64) -> Int {
        Int(remaining / 60_000) + 1
    }
}
