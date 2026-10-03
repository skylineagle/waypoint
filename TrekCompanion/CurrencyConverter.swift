import Foundation

struct CurrencyConverter {
    let displayCurrency: String
    let tripCurrency: String
    let rates: [String: Double]

    init(displayCurrency: String, tripCurrency: String, rates: [String: Double]?) {
        let trip = tripCurrency.uppercased()
        self.tripCurrency = trip
        self.displayCurrency = displayCurrency.uppercased()
        self.rates = rates ?? [:]
    }

    func displayAmount(of item: BudgetItem) -> Double? {
        let currency = (item.currency ?? tripCurrency).uppercased()
        if currency == displayCurrency {
            return item.totalPrice
        }
        if currency == tripCurrency {
            return convert(item.totalPrice, from: tripCurrency)
        }
        if let frozen = item.exchangeRate, frozen > 0, frozen != 1 {
            return convert(item.totalPrice / frozen, from: tripCurrency)
        }
        return convert(item.totalPrice, from: currency)
    }

    func total(of items: [BudgetItem]) -> Double? {
        var total = 0.0
        for item in items {
            guard let amount = displayAmount(of: item) else { return nil }
            total += amount
        }
        return total
    }

    func convert(_ amount: Double, from currency: String) -> Double? {
        convert(amount, from: currency, to: displayCurrency)
    }

    func convert(_ amount: Double, from source: String, to target: String) -> Double? {
        let from = source.uppercased()
        let to = target.uppercased()
        guard from != to else { return amount }
        guard let fromRate = rates[from], let toRate = rates[to],
              fromRate.isFinite, toRate.isFinite, fromRate > 0, toRate > 0
        else { return nil }
        return amount / fromRate * toRate
    }
}
