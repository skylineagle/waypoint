import AppIntents

struct LogExpenseIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Expense"
    static let description = IntentDescription("Adds a cost to your selected Trek trip.")

    @Parameter(title: "Amount", requestValueDialog: "How much was it?")
    var amount: IntentCurrencyAmount

    @Parameter(title: "For", requestValueDialog: "What was it for?")
    var name: String

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$amount) for \(\.$name)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let logged = try await ExpenseLog.add(amount, name: name, note: nil)
        return .result(dialog: logged.dialog, view: logged.snippet)
    }
}
