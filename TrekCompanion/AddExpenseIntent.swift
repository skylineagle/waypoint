import AppIntents
import Foundation

struct AddExpenseIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Expense to Trek"
    static let description = IntentDescription("Adds a Wallet payment to the costs of your selected Trek trip.")

    @Parameter(title: "Amount")
    var amount: Double?

    @Parameter(title: "Merchant")
    var merchant: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$amount) at \(\.$merchant) to Trek")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let client = TrekClient.current, let trip = client.account.trip else {
            throw TrekError("Open Trek Companion and finish setup first.")
        }
        guard let amount else {
            return .result(dialog: "TREK shortcut is ready.")
        }
        let name = merchant ?? "Apple Pay"
        var expense = ExpenseInput(
            name: name,
            category: CostCategory.other.rawValue,
            totalPrice: amount,
            note: ExpenseInput.applePayNote,
            expenseDate: ExpenseDate.today
        )
        if let meID = try? await client.currentUserID() {
            expense.payers = [ExpenseInput.PayerInput(userId: meID, amount: amount)]
        }
        _ = try await client.addExpense(expense, tripID: trip.id)
        return .result(dialog: "Added \(name) to \(trip.title).")
    }
}
