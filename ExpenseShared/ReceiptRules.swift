import Foundation

enum ReceiptRules {
    static func details(from rows: [ReceiptRow], now: Date = .now) -> ReceiptDetails {
        ReceiptDetails(
            merchant: firstTextLine(in: rows),
            total: total(in: rows)?.amount,
            currency: currency(in: rows),
            date: date(in: rows, now: now)
        )
    }

    // MARK: Amounts

    private static let amountPattern = try! NSRegularExpression(
        pattern: #"(-)?\s?(?<![\p{N}])(?<![\p{N}][.,])(\d{1,3}(?:[.,' ]\d{3})+(?:[.,]\d{1,2})?|\d+[.,]\d{1,2})(?![\p{N}%]|[.,]\p{N})"#
    )
    private static let brokenDecimal = try! NSRegularExpression(pattern: #"(\d)([.,]) (\d{2})(?!\d)"#)

    static func amounts(in text: String) -> [Double] {
        let text = brokenDecimal.stringByReplacingMatches(in: text, range: NSRange(text.startIndex..., in: text), withTemplate: "$1$2$3")
        return amountPattern.matches(in: text, range: NSRange(text.startIndex..., in: text)).compactMap { match in
            guard let range = Range(match.range(at: 2), in: text), let value = number(from: String(text[range])) else { return nil }
            return match.range(at: 1).location == NSNotFound ? value : -value
        }
    }

    private static func number(from token: String) -> Double? {
        var digits = token.replacingOccurrences(of: "'", with: "").replacingOccurrences(of: " ", with: "")
        if let separator = digits.last(where: { $0 == "." || $0 == "," }),
           let index = digits.lastIndex(of: separator),
           digits.distance(from: index, to: digits.endIndex) - 1 <= 2 {
            digits = digits[..<index].filter(\.isNumber) + "." + digits[digits.index(after: index)...]
        } else {
            digits = digits.filter(\.isNumber)
        }
        return Double(digits)
    }

    // MARK: Total

    private static let totalWords = [
        "total", "totale", "summe", "suma", "sum", "gesamt", "betrag", "importe", "montant", "amountdue", "topay",
        "합계", "총액", "總計", "总计", "合計", "合计", "סה\"כ", "סה״כ", "לתשלום", "tổngcộng", "jumlah", "итого", "toplam",
    ]
    private static let notTotalWords = [
        "subtotal", "sub-total", "zwischensumme", "subtotale", "小計", "小计", "tax", "vat", "mwst", "iva", "ptu",
        "netto", "item", "disc", "rabat", "change", "cash", "rückgeld", "kembalian", "거스름", "현금", "tip",
    ]

    private static func normalized(_ text: String) -> String {
        text.lowercased().filter { !$0.isWhitespace }
    }

    static func total(in rows: [ReceiptRow]) -> (amount: Double, row: Int)? {
        let candidates = rows.enumerated().compactMap { index, row -> (amount: Double, row: Int, height: Double)? in
            let key = normalized(row.text)
            guard totalWords.contains(where: key.contains), !notTotalWords.contains(where: key.contains),
                  let (amount, amountRow) = amount(on: index, in: rows), amount > 0
            else { return nil }
            return (amount, amountRow, row.height)
        }
        guard let last = candidates.last else { return nil }
        let tallest = candidates.max { $0.height < $1.height }!
        let pick = tallest.height >= last.height * 1.3 ? tallest : last
        return (pick.amount, pick.row)
    }

    private static func amount(on index: Int, in rows: [ReceiptRow]) -> (Double, Int)? {
        if let amount = amounts(in: rows[index].text).last { return (amount, index) }
        let next = index + 1
        guard rows.indices.contains(next), rows[next].text.filter(\.isLetter).count <= 3,
              let amount = amounts(in: rows[next].text).last
        else { return nil }
        return (amount, next)
    }

    private static let tenderWords = ["cash", "change", "bar", "rückgeld", "kembalian", "tunai", "현금", "거스름", "contanti", "efectivo", "espèces", "teruggave", "wisselgeld"]

    static func isPlausibleTotal(_ total: Double, in rows: [ReceiptRow]) -> Bool {
        guard total > 0 else { return false }
        let printedOn = rows.indices.filter { amounts(in: rows[$0].text).contains(total) }
        return printedOn.contains { index in
            let key = normalized(rows[index].text)
            return !tenderWords.contains(where: key.contains)
        }
    }

    // MARK: Currency

    private static let currencyCodes = ["EUR", "USD", "GBP", "CHF", "PLN", "JPY", "KRW", "IDR", "HKD", "TWD", "ILS", "THB", "CZK", "HUF", "SEK", "NOK", "DKK", "CAD", "AUD", "SGD", "MYR", "VND", "TRY", "MXN", "CNY", "INR"]
    private static let currencyMarks: [(String, String)] = [("€", "EUR"), ("£", "GBP"), ("¥", "JPY"), ("円", "JPY"), ("₪", "ILS"), ("₩", "KRW"), ("฿", "THB"), ("zł", "PLN"), ("Kč", "CZK"), ("RMB", "CNY")]
    private static let rupiah = try! NSRegularExpression(pattern: #"\bRp\.?\s?\d"#)

    static func currency(in rows: [ReceiptRow]) -> String? {
        if let row = total(in: rows)?.row, let code = currency(inText: rows[row].text) {
            return code
        }
        let codes = rows.compactMap { currency(inText: $0.text) }
        return Dictionary(grouping: codes, by: { $0 }).max { $0.value.count < $1.value.count }?.key
    }

    static func currencyCode(_ text: String) -> String? {
        currency(inText: text) ?? (text.uppercased().hasPrefix("RP") ? "IDR" : nil)
    }

    private static func currency(inText text: String) -> String? {
        let words = Set(text.uppercased().split { !$0.isLetter })
        if let code = currencyCodes.first(where: { words.contains(Substring($0)) }) { return code }
        if let mark = currencyMarks.first(where: { text.contains($0.0) }) { return mark.1 }
        if rupiah.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil { return "IDR" }
        return nil
    }

    // MARK: Date

    private static let months = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]
    private static let datePatterns: [(NSRegularExpression, (([String]) -> (Int, Int, Int)?))] = [
        (try! NSRegularExpression(pattern: #"(?<!\d)(20\d{2})[-/.](\d{1,2})[-/.](\d{1,2})(?!\d)"#), { ($0[0].int, $0[1].int, $0[2].int) }),
        (try! NSRegularExpression(pattern: #"(?<!\d)(\d{1,2})[./-](\d{1,2})[./-](20\d{2})(?!\d)"#), { dayMonth($0[0].int, $0[1].int, $0[2].int) }),
        (try! NSRegularExpression(pattern: #"(?<!\d)(\d{1,2})[./-](\d{1,2})[./-](\d{2})(?![\d:])"#), { dayMonth($0[0].int, $0[1].int, year($0[2])) }),
        (try! NSRegularExpression(pattern: #"(?<!\d)(20\d{2})(\d{2})(\d{2})(?!\d)"#), { ($0[0].int, $0[1].int, $0[2].int) }),
        (try! NSRegularExpression(pattern: #"(?i)(?<!\d)(\d{1,2})\s?(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*[\s,.']*(\d{2,4})(?!\d)"#), { (year($0[2]), month($0[1]), $0[0].int) }),
        (try! NSRegularExpression(pattern: #"(?i)\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s?(\d{1,2})[\s,.']+(\d{2,4})(?!\d)"#), { (year($0[2]), month($0[0]), $0[1].int) }),
    ]

    private static func dayMonth(_ first: Int, _ second: Int, _ year: Int) -> (Int, Int, Int) {
        second > 12 && first <= 12 ? (year, first, second) : (year, second, first)
    }

    private static func month(_ name: String) -> Int {
        (months.firstIndex(of: String(name.lowercased().prefix(3))) ?? -1) + 1
    }

    private static func year(_ text: String) -> Int {
        guard text.count == 2 else { return text.int }
        let century = Calendar.current.component(.year, from: .now) % 100
        return text.int <= century ? 2000 + text.int : 1900 + text.int
    }

    static func date(in rows: [ReceiptRow], now: Date = .now) -> Date? {
        var dates: [Date] = []
        for row in rows {
            let text = row.text
            for (pattern, parts) in datePatterns {
                for match in pattern.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                    let groups = (1..<match.numberOfRanges).compactMap { Range(match.range(at: $0), in: text).map { String(text[$0]) } }
                    guard let (year, month, day) = parts(groups),
                          let date = DateComponents(calendar: .current, year: year, month: month, day: day).date,
                          (1...12).contains(month), (1...31).contains(day), year >= 1970, date <= now
                    else { continue }
                    dates.append(date)
                }
            }
        }
        return dates.max()
    }

    // MARK: Merchant

    static func firstTextLine(in rows: [ReceiptRow]) -> String? {
        rows.lazy
            .map { $0.text.trimmingCharacters(in: .whitespaces) }
            .first { line in
                let key = normalized(line)
                return line.filter(\.isLetter).count >= 3 && date(in: [ReceiptRow(text: line, height: 0)]) == nil && !totalWords.contains(where: key.contains)
            }
    }
}

private extension String {
    var int: Int { Int(self) ?? 0 }
}
