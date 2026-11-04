import Foundation

/// Textos de Finanzas (ES / EN). En inglés se dice "home", nunca "household".
extension L10n {
    static var financeTitle: String { tr("El Cofre Comunitario", "The Family Chest") }
    static var financeSubtitle: String { tr("El latido financiero de nuestra familia.", "Our family's financial heartbeat.") }
    static var financeNewExpense: String { tr("Nuevo Gasto", "New Expense") }
    static var financeThisMonth: String { tr("Este Mes", "This Month") }
    static var financeSpent: String { tr("Gastado", "Spent") }
    static var financeAverage: String { tr("Promedio", "Average") }
    static var financeBreakdown: String { tr("Desglose de Gastos", "Expense Breakdown") }
    static var financeRecentExpenses: String { tr("Gastos Recientes", "Recent Expenses") }

    static var categoryGroceries: String { tr("Comestibles", "Groceries") }
    static var categoryBills: String { tr("Servicios y Facturas", "Utilities & Bills") }
    static var categoryPet: String { tr("Cuidado de Mascota", "Pet Care") }
    static var categoryLeisure: String { tr("Ocio y Cenas", "Leisure & Dining") }
    static var categoryOther: String { tr("Otros", "Other") }

    static var financeExpenseNameLabel: String { tr("Descripción", "Description") }
    static var financeExpenseNameHint: String { tr("Ej: Supermercado", "E.g.: Groceries") }
    static var financeExpenseCategoryLabel: String { tr("Categoría", "Category") }
    static var financeExpenseAmountLabel: String { tr("Monto", "Amount") }
    static var financeExpenseDateLabel: String { tr("Fecha", "Date") }
    static var financeAddButton: String { tr("Agregar", "Add") }
    static var financeCancelButton: String { tr("Cancelar", "Cancel") }
    static var financeDeleteExpense: String { tr("Eliminar gasto", "Delete expense") }
    static var financeEmptyExpenses: String {
        tr("Aún no has registrado gastos. Toca \"Nuevo Gasto\" para añadir el primero.",
           "No expenses yet. Tap \"New Expense\" to add the first one.")
    }
    static var financeErrorEmptyTitle: String { tr("Escribe una descripción", "Write a description") }
    static var financeErrorInvalidAmount: String {
        tr("Ingresa un monto válido mayor a 0", "Enter a valid amount greater than 0")
    }

    static var financeGoalsTitle: String { tr("Metas de ahorro", "Savings goals") }
    static var financeGoalNew: String { tr("Nueva meta", "New goal") }
    static var financeGoalCreateTitle: String { tr("Crear Meta de Ahorro", "Create Savings Goal") }
    static var financeGoalNameLabel: String { tr("Nombre de la meta", "Goal name") }
    static var financeGoalNameHint: String { tr("Ej: Vacaciones", "E.g.: Vacation") }
    static var financeGoalTargetLabel: String { tr("Monto objetivo", "Target amount") }
    static var financeGoalCreateButton: String { tr("Crear Meta", "Create Goal") }
    static var financeGoalEmptyTitle: String {
        tr("Aún no tienes una meta de ahorro.", "You don't have a savings goal yet.")
    }
    static var financeGoalEmptyAction: String { tr("Crear meta", "Create goal") }
    static var financeGoalDeleteTitle: String { tr("¿Eliminar meta?", "Delete goal?") }
    static func financeGoalDeleteMessage(_ title: String) -> String {
        tr("Se eliminará \"\(title)\" junto con su progreso.", "\"\(title)\" and its progress will be deleted.")
    }
    static var financeGoalDeleteButton: String { tr("Eliminar", "Delete") }
    static func financeGoalContributeTo(_ title: String) -> String {
        tr("Aportar a \(title)", "Contribute to \(title)")
    }
    static var financeGoalContributeAmountLabel: String { tr("Monto a aportar", "Amount to contribute") }
    static var financeGoalContributeButton: String { tr("Aportar", "Contribute") }
    static func financeSavingsProgress(_ current: String, _ target: String) -> String { "\(current) / \(target)" }
}
