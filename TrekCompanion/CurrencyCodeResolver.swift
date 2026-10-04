import Foundation

enum CurrencyCodeResolver {
    private static let invisibleMarks = CharacterSet(charactersIn: "\u{200E}\u{200F}\u{061C}\u{202A}\u{202B}\u{202C}")

    static func code(from text: String, amount: Double, locale: Locale = .current) -> String? {
        let cleaned = String(text.unicodeScalars.filter { !invisibleMarks.contains($0) })
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let isoCodes = Locale.commonISOCurrencyCodes
        if isoCodes.contains(cleaned.uppercased()) { return cleaned.uppercased() }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return isoCodes.first { code in
            formatter.currencyCode = code
            guard let parsed = formatter.number(from: cleaned)?.doubleValue else { return false }
            return abs(parsed - amount) < 0.005
        }
    }
}
