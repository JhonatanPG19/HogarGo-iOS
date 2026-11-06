import Foundation
import Observation

/// ViewModel de Finanzas (MVVM).
///
/// Reglas para que la vista siempre esté al día (el error de las listas que no se actualizaban
/// ocurría por leer con un `fetch` suelto dentro de `body`):
/// 1. Los datos viven en propiedades `@Observable` (`expenses`, `goals`); al reasignarlas, SwiftUI redibuja.
/// 2. Toda acción termina llamando a `reload()`.
/// 3. `start()` se suscribe a `ModelContext.didSave`, así también se recarga cuando el cambio
///    lo hizo otra pantalla o una hoja que escribe directo en el repositorio.
@MainActor
@Observable
final class FinanceViewModel {
    // MARK: Estado que observa la vista

    private(set) var expenses: [Expense] = []
    private(set) var goals: [SavingsGoal] = []

    // MARK: Dependencias

    let householdId: String
    @ObservationIgnored private let repository: FinanceRepository
    @ObservationIgnored private var observer: SaveObserver?

    init(householdId: String, repository: FinanceRepository) {
        self.householdId = householdId
        self.repository = repository
    }

    /// Se llama una vez al aparecer la pantalla: lee los datos y escucha los guardados.
    func start() {
        guard observer == nil else { return }
        observer = SaveObserver(context: repository.context) { [weak self] in
            self?.reload()
        }
        reload()
    }

    /// Única función que lee de la base. Siempre reasigna las propiedades observadas.
    func reload() {
        expenses = repository.expenses(householdId: householdId)
        goals = repository.goals(householdId: householdId)
    }

    // MARK: Estado derivado (lo que pinta la vista)

    var monthExpenses: [Expense] { FinanceSummary.monthExpenses(expenses) }
    var monthTotal: Double { FinanceSummary.total(monthExpenses) }
    var monthAverage: Double { FinanceSummary.average(monthExpenses) }
    var breakdown: [CategoryTotal] { FinanceSummary.breakdown(monthExpenses) }

    // MARK: Acciones

    func addExpense(title: String, category: ExpenseCategory, amount: Double?, dateISO: String) throws {
        try repository.addExpense(
            householdId: householdId,
            title: title,
            category: category,
            amount: amount,
            dateISO: dateISO
        )
        reload()
    }

    func deleteExpense(_ expense: Expense) {
        try? repository.deleteExpense(expense)
        reload()
    }

    func addGoal(title: String, targetAmount: Double?) throws {
        try repository.addGoal(householdId: householdId, title: title, targetAmount: targetAmount)
        reload()
    }

    func deleteGoal(_ goal: SavingsGoal) {
        try? repository.deleteGoal(goal)
        reload()
    }

    func contribute(to goal: SavingsGoal, amount: Double?) throws {
        try repository.contribute(to: goal, amount: amount)
        reload()
    }
}
