import Foundation

nonisolated enum ExchangeRates {
    static func fetch(base: String) async throws -> [String: Double] {
        let url = URL(string: "https://api.frankfurter.dev/v2/rates?base=\(base.uppercased())")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let quotes = try JSONDecoder().decode([Quote].self, from: data)
        var rates = [base.uppercased(): 1.0]
        guard !quotes.isEmpty else { throw URLError(.cannotParseResponse) }
        for quote in quotes where quote.rate.isFinite && quote.rate > 0 {
            rates[quote.quote] = quote.rate
        }
        return rates
    }

    private struct Quote: Decodable {
        let quote: String
        let rate: Double
    }
}
