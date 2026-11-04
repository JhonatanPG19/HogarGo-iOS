import Foundation
import SwiftData

enum ExpenseCategory: String, CaseIterable, Identifiable {
    case groceries
    case bills
    case pet
    case leisure
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .groceries: return L10n.categoryGroceries
        case .bills: return L10n.categoryBills
        case .pet: return L10n.categoryPet
        case .leisure: return L10n.categoryLeisure
        case .other: return L10n.categoryOther
        }
    }

    /// Símbolo SF equivalente al icono de Material usado en Android.
    var iconName: String {
        switch self {
        case .groceries: return "cart"
        case .bills: return "bolt"
        case .pet: return "pawprint"
        case .leisure: return "fork.knife"
        case .other: return "ellipsis"
        }
    }
}

/// Gasto del hogar. La fecha se guarda como texto ISO "yyyy-MM-dd".
@Model
final class Expense {
    var id: String
    var householdId: String
    var title: String
    var categoryRaw: String
    var amount: Double
    var dateISO: String
    /// Desempate de orden (más reciente primero cuando la fecha coincide).
    var createdAt: Int64

    init(
        id: String = UUID().uuidString,
        householdId: String,
        title: String,
        category: ExpenseCategory,
        amount: Double,
        dateISO: String,
        createdAt: Int64 = Clock.nowMillis()
    ) {
        self.id = id
        self.householdId = householdId
        self.title = title
        self.categoryRaw = category.rawValue
        self.amount = amount
        self.dateISO = dateISO
        self.createdAt = createdAt
    }

    var category: ExpenseCategory {
        get { ExpenseCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
}
