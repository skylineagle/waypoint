struct BudgetItem {
    var totalPrice: Double
    var currency: String?
    var exchangeRate: Double?
}

func expect(_ actual: Double, _ expected: Double, _ label: String) {
    precondition(abs(actual - expected) < 0.01, "\(label): expected \(expected), got \(actual)")
    print("ok  \(label)")
}

let rates = ["ILS": 1, "JPY": 52.107, "USD": 0.27]
let converter = CurrencyConverter(displayCurrency: "ILS", tripCurrency: "JPY", rates: rates)

expect(converter.displayAmount(of: BudgetItem(totalPrice: 5210.7)), 100, "trip currency converts live")
expect(converter.displayAmount(of: BudgetItem(totalPrice: 100, currency: "ILS", exchangeRate: 0.02)), 95.96, "frozen rate goes through trip currency")
expect(converter.displayAmount(of: BudgetItem(totalPrice: 100, currency: "ILS", exchangeRate: 1)), 100, "rate of 1 is unfrozen and converts live")
expect(converter.displayAmount(of: BudgetItem(totalPrice: 27, currency: "USD")), 100, "foreign currency converts live")
expect(converter.convert(1, from: "JPY", to: "ILS") * 52.107, 1, "round trip rate")

let offline = CurrencyConverter(displayCurrency: "ILS", tripCurrency: "JPY", rates: nil)
precondition(offline.displayCurrency == "JPY", "offline falls back to trip currency")
expect(offline.displayAmount(of: BudgetItem(totalPrice: 1000)), 1000, "offline shows trip amounts")
print("all currency checks passed")
