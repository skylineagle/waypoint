import Foundation

struct CurrencyConverter {
    let displayCurrency: String
    let tripCurrency: String
    let rates: [String: Double]

    init(displayCurrency: String, tripCurrency: String, rates: [String: Double]?) {
        let trip = tripCurrency.uppercased()
        let hasRates = rates != nil
        self.tripCurrency = trip
        self.displayCurrency = hasRates ? displayCurrency.uppercased() : trip
        self.rates = rates ?? [trip: 1]
    }

    func displayAmount(of item: BudgetItem) -> Double {
        let currency = (item.currency ?? tripCurrency).uppercased()
        if currency == tripCurrency {
            return convert(item.totalPrice, from: tripCurrency)
        }
        if let frozen = item.exchangeRate, frozen > 0, frozen != 1 {
            return convert(item.totalPrice / frozen, from: tripCurrency)
        }
        return convert(item.totalPrice, from: currency)
    }

    func convert(_ amount: Double, from currency: String) -> Double {
        convert(amount, from: currency, to: displayCurrency)
    }

    func convert(_ amount: Double, from source: String, to target: String) -> Double {
        let from = source.uppercased()
        let to = target.uppercased()
        guard from != to, let fromRate = rates[from], let toRate = rates[to], fromRate > 0 else { return amount }
        return amount / fromRate * toRate
    }
}
