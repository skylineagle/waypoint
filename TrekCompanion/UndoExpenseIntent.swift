import AppIntents

struct UndoExpenseIntent: AppIntent {
    static let title: LocalizedStringResource = "Undo Expense"
    static let isDiscoverable = false

    @Parameter(title: "Expense") var expenseID: Int
    @Parameter(title: "Trip") var tripID: Int

    init() {}

    init(expenseID: Int, tripID: Int) {
        self.expenseID = expenseID
        self.tripID = tripID
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let client = TrekClient.current else { throw TrekError("Open Waypoint and finish setup first.") }
        try await client.deleteExpense(id: expenseID, tripID: tripID)
        return .result(dialog: "Removed it.")
    }
}
