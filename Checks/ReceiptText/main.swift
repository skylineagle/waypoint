import Foundation

func expect<T: Equatable>(_ actual: T, _ expected: T, _ label: String) {
    precondition(actual == expected, "\(label): expected \(expected), got \(actual)")
    print("ok  \(label)")
}

func rows(_ lines: [String]) -> [ReceiptRow] {
    lines.map { ReceiptRow(text: $0, height: 1) }
}

func day(_ date: Date?) -> String {
    guard let date else { return "-" }
    let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
    return String(format: "%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
}

let now = ISO8601DateFormatter().date(from: "2026-09-28T12:00:00Z")!

let italian = rows(["TRATTORIA MARIO", "27/09/2026  20:14", "Pasta x2  26,00", "SUBTOTALE  38,00", "IVA 10%  3,82", "TOTALE €  42,00", "Grazie"])
expect(ReceiptRules.total(in: italian)?.amount, 42, "total row wins over subtotal and tax")
expect(ReceiptRules.currency(in: italian), "EUR", "euro symbol")
expect(ReceiptRules.firstTextLine(in: italian), "TRATTORIA MARIO", "first text line")
expect(day(ReceiptRules.date(in: italian, now: now)), "2026-09-27", "date next to a time")

let stacked = rows(["合計", "¥1,240", "お預り  ¥2,000"])
expect(ReceiptRules.total(in: stacked)?.amount, 1240, "amount on the row under the total word")

expect(ReceiptRules.amounts(in: "Steuernummer: DE273010747"), [], "long id is not an amount")
expect(ReceiptRules.amounts(in: "IVA 22,00%"), [], "percentage is not an amount")
expect(ReceiptRules.amounts(in: "TOTAL 1.234,50"), [1234.5], "european thousands")
expect(ReceiptRules.amounts(in: "TOTAL 1,234.50"), [1234.5], "us thousands")
expect(ReceiptRules.amounts(in: "Summe EUR  34, 09"), [34.09], "space after decimal comma")

let cash = rows(["TOTAL  19.50", "Cash  20.00", "CHANGE  0.50"])
expect(ReceiptRules.isPlausibleTotal(19.5, in: cash), true, "printed total is plausible")
expect(ReceiptRules.isPlausibleTotal(20, in: cash), false, "cash handed over is not the total")
expect(ReceiptRules.isPlausibleTotal(55, in: cash), false, "unprinted amount is not the total")

expect(day(ReceiptRules.date(in: rows(["Time 16:33"]), now: now)), "-", "a bare time is not a date")
expect(day(ReceiptRules.date(in: rows(["19/04/94 19:04"]), now: now)), "1994-04-19", "two digit year before 2000")
expect(day(ReceiptRules.date(in: rows(["DATE: 09/07/2014", "Date 06/03/2019"]), now: now)), "2019-03-06", "latest past date wins")
expect(day(ReceiptRules.date(in: rows(["Feb15'06 07:20PM"]), now: now)), "2006-02-15", "month name date")
