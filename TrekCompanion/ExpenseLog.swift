import AppIntents
import Foundation

enum ExpenseLog {
    struct Logged {
        let dialog: IntentDialog
        let snippet: ExpenseAddedSnippet
    }

    @MainActor
    static func add(_ amount: IntentCurrencyAmount, name: String?, note: String?) async throws -> Logged {
        guard let client = TrekClient.current, let trip = client.account.trip else {
            throw TrekError("Open Waypoint and finish setup first.")
        }
        let totalPrice = NSDecimalNumber(decimal: amount.amount).doubleValue
        let category = if let name { await ExpenseCategorizer.category(for: name) } else { CostCategory.other }
        let name = name ?? "Apple Pay"
        var expense = ExpenseInput(
            name: name,
            category: category.rawValue,
            totalPrice: totalPrice,
            currency: amount.currencyCode,
            note: note,
            expenseDate: ExpenseDate.today
        )
        if let meID = try? await client.currentUserID() {
            expense.payers = [ExpenseInput.PayerInput(userId: meID, amount: totalPrice)]
        }
        let saved = try await client.addExpense(expense, tripID: trip.id)
        return Logged(
            dialog: "Added \(name) to \(trip.title) as \(category.label).",
            snippet: ExpenseAddedSnippet(expense: saved, tripID: trip.id, category: category)
        )
    }
}
