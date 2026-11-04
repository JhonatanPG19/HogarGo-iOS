import Foundation
import SwiftData

/// Factura del hogar con fecha de vencimiento ISO "yyyy-MM-dd".
@Model
final class Bill {
    var id: String
    var householdId: String
    var title: String
    var amount: Double
    var dueDateISO: String
    var paid: Bool

    init(
        id: String = UUID().uuidString,
        householdId: String,
        title: String,
        amount: Double,
        dueDateISO: String,
        paid: Bool = false
    ) {
        self.id = id
        self.householdId = householdId
        self.title = title
        self.amount = amount
        self.dueDateISO = dueDateISO
        self.paid = paid
    }
}
