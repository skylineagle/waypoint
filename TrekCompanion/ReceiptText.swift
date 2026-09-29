import Foundation

struct ReceiptDetails: Equatable {
    var merchant: String?
    var total: Double?
    var currency: String?
    var date: Date?
}

enum ReceiptText {
    private static let totalWords = ["total", "totale", "summe", "gesamt", "importe", "montant", "betrag", "amount due", "to pay", "合計", "合计", "סה\"כ", "סה״כ", "לתשלום"]
    private static let excludedWords = ["subtotal", "sub total", "sub-total", "zwischensumme", "subtotale", "小計", "tax", "vat", "mwst", "iva"]
    private static let currencySymbols: [(String, String)] = [("€", "EUR"), ("£", "GBP"), ("¥", "JPY"), ("円", "JPY"), ("₪", "ILS"), ("₩", "KRW"), ("฿", "THB"), ("CHF", "CHF")]

    static func details(from lines: [String], now: Date = .now) -> ReceiptDetails {
        let text = lines.joined(separator: "\n")
        return ReceiptDetails(
            merchant: merchant(in: lines),
            total: total(in: lines),
            currency: currencySymbols.first { text.contains($0.0) }?.1,
            date: date(in: text, now: now)
        )
    }

    static func amount(in line: String) -> Double? {
        let pattern = #/\d{1,3}(?:[.,' ]\d{3})*(?:[.,]\d{1,2})?|\d+(?:[.,]\d{1,2})?/#
        guard let token = line.matches(of: pattern).last.map({ String($0.output) }) else { return nil }
        return number(from: token)
    }

    private static func number(from token: String) -> Double? {
        var digits = token.replacingOccurrences(of: "'", with: "").replacingOccurrences(of: " ", with: "")
        let decimalSeparator = digits.last { $0 == "." || $0 == "," }
        if let decimalSeparator, let index = digits.lastIndex(of: decimalSeparator),
           digits.distance(from: index, to: digits.endIndex) - 1 <= 2 {
            let whole = digits[..<index].filter(\.isNumber)
            digits = whole + "." + digits[digits.index(after: index)...]
        } else {
            digits = digits.filter(\.isNumber)
        }
        return Double(digits)
    }

    private static func total(in lines: [String]) -> Double? {
        let normalized = lines.map { $0.lowercased() }
        let totalIndex = normalized.indices.last { index in
            totalWords.contains { normalized[index].contains($0) } && !excludedWords.contains { normalized[index].contains($0) }
        }
        if let totalIndex {
            let candidates = [lines[totalIndex]] + lines.dropFirst(totalIndex + 1).prefix(1)
            if let amount = candidates.lazy.compactMap(amount(in:)).first(where: { $0 > 0 }) {
                return amount
            }
        }
        return lines.filter { !isDateLike($0) }.compactMap(amount(in:)).max()
    }

    private static func merchant(in lines: [String]) -> String? {
        lines.lazy
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { line in line.filter(\.isLetter).count >= 3 && !isDateLike(line) && !totalWords.contains { line.lowercased().contains($0) } }
    }

    private static func isDateLike(_ line: String) -> Bool {
        line.contains(#/\d{1,4}[.\/-]\d{1,2}[.\/-]\d{2,4}/#)
    }

    private static func date(in text: String, now: Date) -> Date? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let range = NSRange(text.startIndex..., in: text)
        return detector?.matches(in: text, range: range)
            .compactMap(\.date)
            .first { $0 <= now }
    }
}
