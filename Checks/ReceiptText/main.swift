import Foundation
func expect<T: Equatable>(_ a: T, _ b: T, _ label: String) { precondition(a == b, "\(label): expected \(b), got \(a)"); print("ok  \(label)") }
let now = ISO8601DateFormatter().date(from: "2026-09-28T12:00:00Z")!
let italian = ReceiptText.details(from: ["TRATTORIA MARIO", "Via Roma 12", "27/09/2026", "Pasta x2 26,00", "Vino 12,00", "SUBTOTALE 38,00", "TOTALE € 42,00", "Grazie"], now: now)
expect(italian.merchant, "TRATTORIA MARIO", "merchant is first text line")
expect(italian.total, 42, "total line wins over subtotal")
expect(italian.currency, "EUR", "euro symbol")
expect(italian.date != nil, true, "date found")
let japanese = ReceiptText.details(from: ["ローソン", "2026/09/27", "おにぎり ¥180", "合計", "¥1,240"], now: now)
expect(japanese.total, 1240, "amount on the line after the total word, thousands separator")
expect(japanese.currency, "JPY", "yen")
expect(ReceiptText.details(from: ["CAFE", "Latte 4.50", "Cake 6.20"]).total, 6.2, "falls back to largest amount")
expect(ReceiptText.amount(in: "TOTAL 1.234,50"), 1234.5, "european thousands")
expect(ReceiptText.amount(in: "TOTAL 1,234.50"), 1234.5, "us thousands")
