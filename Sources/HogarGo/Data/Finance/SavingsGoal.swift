import Foundation
import SwiftData

/// Meta de ahorro del hogar. `currentAmount` puede superar a `targetAmount`;
/// el progreso visual se recorta a 1.0.
@Model
final class SavingsGoal {
    var id: String
    var householdId: String
    var title: String
    var currentAmount: Double
    var targetAmount: Double
    var createdAt: Int64

    init(
        id: String = UUID().uuidString,
        householdId: String,
        title: String,
        currentAmount: Double = 0,
        targetAmount: Double,
        createdAt: Int64 = Clock.nowMillis()
    ) {
        self.id = id
        self.householdId = householdId
        self.title = title
        self.currentAmount = currentAmount
        self.targetAmount = targetAmount
        self.createdAt = createdAt
    }

    /// Progreso entre 0 y 1.
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(max(currentAmount / targetAmount, 0), 1)
    }
}
