import AppIntents
import Foundation

struct AddExpenseIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Expense to Trek"
    static let description = IntentDescription("Adds a Wallet payment to the costs of your selected Trek trip.")

    @Parameter(title: "Amount")
    var amount: IntentCurrencyAmount?

    @Parameter(title: "Merchant")
    var merchant: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$amount) at \(\.$merchant) to Trek")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let client = TrekClient.current, let trip = client.account.trip else {
            throw TrekError("Open Waypoint and finish setup first.")
        }
        guard let amount else {
            return .result(dialog: "TREK shortcut is ready.")
        }
        let totalPrice = NSDecimalNumber(decimal: amount.amount).doubleValue
        let name = merchant ?? "Apple Pay"
        let category = merchant == nil ? CostCategory.other : await ExpenseCategorizer.category(for: name)
        var expense = ExpenseInput(
            name: name,
            category: category.rawValue,
            totalPrice: totalPrice,
            currency: amount.currencyCode,
            note: ExpenseInput.applePayNote,
            expenseDate: ExpenseDate.today
        )
        if let meID = try? await client.currentUserID() {
            expense.payers = [ExpenseInput.PayerInput(userId: meID, amount: totalPrice)]
        }
        _ = try await client.addExpense(expense, tripID: trip.id)
        return .result(dialog: "Added \(name) to \(trip.title) as \(category.label).")
    }
}
