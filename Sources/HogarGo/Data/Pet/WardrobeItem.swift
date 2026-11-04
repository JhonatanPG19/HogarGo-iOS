import Foundation
import SwiftData

/// Ropero del hogar: una fila por (hogar, objeto del catálogo).
@Model
final class WardrobeItem {
    var householdId: String
    /// "scarf" | "ball" | "glasses" | "skateboard"
    var itemId: String
    var owned: Bool
    var equipped: Bool

    init(householdId: String, itemId: String, owned: Bool = false, equipped: Bool = false) {
        self.householdId = householdId
        self.itemId = itemId
        self.owned = owned
        self.equipped = equipped
    }
}
