import AppIntents
import Foundation
import SwiftUI

enum CostCategory: String {
    case food, other
    init(stored: String?) { self = Self(rawValue: stored ?? "") ?? .other }
    var label: String { rawValue.capitalized }
}

enum ExpenseCategorizer {
    static func category(for merchant: String) async -> CostCategory { .food }
}

@MainActor
struct TrekClient {
    static var current: TrekClient? = TrekClient()
    static var recorded: ExpenseInput?
    let account = TestAccount()

    func currentUserID() async throws -> Int { 7 }
    func addExpense(_ input: ExpenseInput, tripID: Int) async throws -> BudgetItem {
        precondition(tripID == 42)
        Self.recorded = input
        return BudgetItem(id: 1, name: input.name, category: input.category ?? "other", totalPrice: input.totalPrice, currency: input.currency)
    }
}

struct ExpenseAddedSnippet: View {
    let expense: BudgetItem
    let tripID: Int
    let category: CostCategory

    var body: some View { EmptyView() }
}

struct TestAccount {
    let trip: Trip? = Trip(id: 42, title: "Test trip", currency: "JPY", startDate: nil, endDate: nil)
}

@main
struct ShortcutCurrencyCheck {
    @MainActor
    static func main() async throws {
        let intent = AddExpenseIntent()
        intent.amount = IntentCurrencyAmount(amount: Decimal(string: "12.34")!, currencyCode: "ILS")
        intent.merchant = "Starbucks Test"
        _ = try await intent.perform()
        let input = TrekClient.recorded!
        precondition(input.totalPrice == 12.34)
        precondition(input.currency == "ILS")
        precondition(input.payers?.first?.amount == 12.34)
        let payload = String(decoding: try JSONEncoder().encode(input), as: UTF8.self)
        precondition(payload.contains("\"currency\":\"ILS\""))

        TrekClient.recorded = nil
        intent.amount = nil
        _ = try await intent.perform()
        precondition(TrekClient.recorded == nil)
        print("Shortcut preserves foreign currency and amount; readiness check creates no expense.")
    }
}
