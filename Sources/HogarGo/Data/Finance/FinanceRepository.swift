import Foundation
import SwiftData

enum FinanceError: Error {
    case emptyTitle
    case invalidAmount
    case unknown
}

/// Un renglón del desglose por categoría.
struct CategoryTotal: Identifiable {
    let category: ExpenseCategory
    let amount: Double
    /// `amount / totalSpent` del mes (0 si no hay gasto).
    let fraction: Double
    var id: String { category.rawValue }
}

/// Cálculos puros de Finanzas (sin base de datos) para poder probarlos fácilmente.
enum FinanceSummary {
    /// Gastos cuyo año-mes coincide con el de `today` ("yyyy-MM-dd").
    static func monthExpenses(_ expenses: [Expense], today: String = ISODay.today()) -> [Expense] {
        let key = ISODay.monthKey(of: today)
        return expenses.filter { ISODay.monthKey(of: $0.dateISO) == key }
    }

    static func total(_ expenses: [Expense]) -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    /// Promedio por gasto (0 si no hay gastos).
    static func average(_ expenses: [Expense]) -> Double {
        expenses.isEmpty ? 0 : total(expenses) / Double(expenses.count)
    }

    /// Gastos del mes agrupados por categoría, de mayor a menor monto.
    static func breakdown(_ monthExpenses: [Expense]) -> [CategoryTotal] {
        let spent = total(monthExpenses)
        var sums: [ExpenseCategory: Double] = [:]
        for expense in monthExpenses {
            sums[expense.category, default: 0] += expense.amount
        }
        return sums
            .map { CategoryTotal(category: $0.key, amount: $0.value, fraction: spent > 0 ? $0.value / spent : 0) }
            .sorted { $0.amount > $1.amount }
    }
}

enum FinanceFormat {
    /// "$" + dos decimales, ej. `$1250.50`.
    static func money(_ value: Double) -> String {
        "$" + String(format: "%.2f", value)
    }

    /// Acepta coma o punto decimal. Devuelve `nil` si no es un número.
    static func parseAmount(_ text: String) -> Double? {
        let normalized = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    /// Deja solo dígitos, `.` y `,` (máximo 12 caracteres).
    static func sanitizeAmountInput(_ text: String) -> String {
        String(text.filter { $0.isNumber || $0 == "." || $0 == "," }.prefix(12))
    }
}

/// Gastos y metas de ahorro del hogar.
@MainActor
final class FinanceRepository {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Lecturas

    /// Gastos del hogar: fecha descendente y, a igual fecha, el más reciente primero.
    func expenses(householdId: String) -> [Expense] {
        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate { $0.householdId == householdId },
            sortBy: [
                SortDescriptor(\.dateISO, order: .reverse),
                SortDescriptor(\.createdAt, order: .reverse),
            ]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Metas de ahorro del hogar, de la más antigua a la más reciente.
    func goals(householdId: String) -> [SavingsGoal] {
        let descriptor = FetchDescriptor<SavingsGoal>(
            predicate: #Predicate { $0.householdId == householdId },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - Gastos

    @discardableResult
    func addExpense(
        householdId: String,
        title rawTitle: String,
        category: ExpenseCategory,
        amount: Double?,
        dateISO: String = ISODay.today()
    ) throws -> Expense {
        let title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw FinanceError.emptyTitle }
        guard let amount, amount > 0 else { throw FinanceError.invalidAmount }

        let expense = Expense(
            householdId: householdId,
            title: title,
            category: category,
            amount: amount,
            dateISO: dateISO
        )
        context.insert(expense)
        try saveContext()
        return expense
    }

    func deleteExpense(_ expense: Expense) throws {
        context.delete(expense)
        try saveContext()
    }

    // MARK: - Metas

    @discardableResult
    func addGoal(householdId: String, title rawTitle: String, targetAmount: Double?) throws -> SavingsGoal {
        let title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw FinanceError.emptyTitle }
        guard let targetAmount, targetAmount > 0 else { throw FinanceError.invalidAmount }

        let goal = SavingsGoal(householdId: householdId, title: title, targetAmount: targetAmount)
        context.insert(goal)
        try saveContext()
        return goal
    }

    func deleteGoal(_ goal: SavingsGoal) throws {
        context.delete(goal)
        try saveContext()
    }

    /// Suma `amount` al progreso. Puede superar la meta.
    func contribute(to goal: SavingsGoal, amount: Double?) throws {
        guard let amount, amount > 0 else { throw FinanceError.invalidAmount }
        goal.currentAmount += amount
        try saveContext()
    }

    // MARK: - Privado

    private func saveContext() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw FinanceError.unknown
        }
    }
}
