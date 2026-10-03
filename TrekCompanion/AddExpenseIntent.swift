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
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let amount else {
            return .result(dialog: "TREK shortcut is ready.", view: nil as ExpenseAddedSnippet?)
        }
        let logged = try await ExpenseLog.add(amount, name: merchant, note: ExpenseInput.applePayNote)
        return .result(dialog: logged.dialog, view: logged.snippet)
    }
}
