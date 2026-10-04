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
        intent.amount = 12.34
        intent.currencyCode = "ILS"
        intent.merchant = "Starbucks Test"
        _ = try await intent.perform()
        let input = TrekClient.recorded!
        precondition(input.totalPrice == 12.34)
        precondition(input.currency == "ILS")
        precondition(input.payers?.first?.amount == 12.34)
        let payload = String(decoding: try JSONEncoder().encode(input), as: UTF8.self)
        precondition(payload.contains("\"currency\":\"ILS\""))

        let us = Locale(identifier: "en_US")
        precondition(CurrencyCodeResolver.code(from: "$12.34", amount: 12.34, locale: us) == "USD")
        precondition(CurrencyCodeResolver.code(from: "€1,234.50", amount: 1234.5, locale: us) == "EUR")
        precondition(CurrencyCodeResolver.code(from: "\u{200F}¥1,200", amount: 1200, locale: us) == "JPY")
        precondition(CurrencyCodeResolver.code(from: "12.34", amount: 12.34, locale: us) == nil)

        TrekClient.recorded = nil
        intent.currencyCode = nil
        _ = try await intent.perform()
        precondition(TrekClient.recorded?.currency == "JPY")

        TrekClient.recorded = nil
        intent.amount = nil
        _ = try await intent.perform()
        precondition(TrekClient.recorded == nil)
        print("Shortcut preserves foreign currency and amount; readiness check creates no expense.")
    }
}
