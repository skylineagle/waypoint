import Foundation

enum CostCategory: String {
    case transport, other
    init(stored: String?) { self = Self(rawValue: stored ?? "") ?? .other }
}

@main
struct CurrencyDisplayCheck {
    static func main() throws {
        let json = #"{"id":1,"name":"Shinkansen","category":"transport","total_price":733,"currency":"ILS","exchange_rate":0.0245}"#
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let item = try decoder.decode(BudgetItem.self, from: Data(json.utf8))
        let converter = CurrencyConverter(displayCurrency: "ILS", tripCurrency: "JPY", rates: ["ILS": 1, "JPY": 40.6])
        precondition(converter.displayAmount(of: item) == 733, "an expense entered in the display currency must show as entered")
        let unavailable = CurrencyConverter(displayCurrency: "ILS", tripCurrency: "JPY", rates: nil)
        precondition(unavailable.displayCurrency == "ILS")
        precondition(unavailable.convert(100, from: "JPY") == nil)
        precondition(unavailable.convert(100, from: "ILS") == 100)
        precondition(unavailable.displayAmount(of: item) == 733)
        precondition(converter.convert(100, from: "THB") == nil)
        let invalid = CurrencyConverter(displayCurrency: "ILS", tripCurrency: "JPY", rates: ["ILS": 1, "JPY": 0, "USD": .infinity, "EUR": -1])
        precondition(invalid.convert(100, from: "JPY") == nil)
        precondition(invalid.convert(100, from: "USD") == nil)
        precondition(invalid.convert(100, from: "EUR") == nil)
        let yen = BudgetItem(id: 2, name: "Lunch", category: "other", totalPrice: 4060, currency: "JPY")
        precondition(converter.displayAmount(of: yen) == 100)
        precondition(unavailable.displayAmount(of: yen) == nil)
        precondition(unavailable.total(of: [item, yen]) == nil)
        precondition(converter.total(of: [item, yen]) == 833)
        precondition(unavailable.total(of: []) == 0)
        let frozen = BudgetItem(id: 3, name: "Coffee", category: "other", totalPrice: 10, currency: "EUR", exchangeRate: 0.05)
        precondition(abs(converter.displayAmount(of: frozen)! - 200 / 40.6) < 0.000001)
        print("Currency display checks passed, including unavailable, missing, invalid, and frozen rates.")
    }
}
