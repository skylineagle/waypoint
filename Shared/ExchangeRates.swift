import Foundation

nonisolated enum ExchangeRates {
    static func fetch(base: String) async throws -> [String: Double] {
        let url = URL(string: "https://api.frankfurter.dev/v2/rates?base=\(base.uppercased())")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let quotes = try JSONDecoder().decode([Quote].self, from: data)
        var rates = [base.uppercased(): 1.0]
        for quote in quotes {
            rates[quote.quote] = quote.rate
        }
        return rates
    }

    private struct Quote: Decodable {
        let quote: String
        let rate: Double
    }
}
