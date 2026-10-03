import Foundation

@main
struct CurrencyDisplayCheck {
    static func main() throws {
        let json = #"{"id":1,"name":"Shinkansen","category":"transport","total_price":733,"currency":"ILS","exchange_rate":0.0245}"#
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let item = try decoder.decode(BudgetItem.self, from: Data(json.utf8))
        let converter = CurrencyConverter(displayCurrency: "ILS", tripCurrency: "JPY", rates: ["ILS": 1, "JPY": 40.6])
        precondition(converter.displayAmount(of: item) == 733, "an expense entered in the display currency must show as entered")
        print("CurrencyDisplay OK")
    }
}
