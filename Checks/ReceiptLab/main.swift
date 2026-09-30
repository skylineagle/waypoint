import Foundation
import ImageIO
import Vision

struct Truth: Decodable {
    let file: String
    let merchant: [String]
    let total: Double?
    let currency: [String]
    let date: String?
}

enum Field: String, CaseIterable { case merchant, total, currency, date }

func passes(_ field: Field, _ details: ReceiptDetails, _ truth: Truth) -> Bool {
    switch field {
    case .merchant:
        guard let merchant = details.merchant?.lowercased() else { return truth.merchant.isEmpty }
        return truth.merchant.contains { merchant.contains($0) }
    case .total:
        guard let total = details.total else { return truth.total == nil }
        return truth.total.map { abs($0 - total) < 0.005 } ?? false
    case .currency:
        return truth.currency.contains(details.currency ?? "")
    case .date:
        guard let date = details.date else { return truth.date == nil }
        return truth.date == dayString(date)
    }
}

func dayString(_ date: Date) -> String {
    let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
    return String(format: "%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
}

func show(_ details: ReceiptDetails) -> String {
    let total = details.total.map { String($0) } ?? "-"
    return "\(details.merchant ?? "-") | \(total) | \(details.currency ?? "-") | \(details.date.map(dayString) ?? "-")"
}

let arguments = CommandLine.arguments.dropFirst()
guard let folder = arguments.first else {
    print("usage: scripts/receipt-lab.sh <receipt folder> [truth.json] [verbose]")
    exit(1)
}
let verbose = arguments.contains("verbose")
let truthName = arguments.first { $0.hasSuffix(".json") } ?? "truth.json"
let truthURL = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appending(path: truthName)
let truths = try JSONDecoder().decode([Truth].self, from: Data(contentsOf: truthURL))
let now = ISO8601DateFormatter().date(from: "2026-09-29T23:59:00Z")!
let pipelines = ["rules only", "model only", "app"]
var scores = Dictionary(uniqueKeysWithValues: pipelines.map { ($0, [Field: Int]()) })
print("model available:", ReceiptModel.isAvailable)

for truth in truths {
    let url = URL(fileURLWithPath: folder).appending(path: truth.file)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil), let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        print("!! missing \(truth.file)")
        continue
    }
    var request = RecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.automaticallyDetectsLanguage = true
    let rows = ReceiptRows.rows(from: try await request.perform(on: image))
    let results: [String: ReceiptDetails] = [
        "rules only": ReceiptRules.details(from: rows, now: now),
        "model only": await ReceiptModel.details(from: rows, now: now),
        "app": await ReceiptParser.details(from: rows, now: now),
    ]
    print("\n== \(truth.file)")
    if verbose { rows.forEach { print("   │ \($0.text)") } }
    for name in pipelines {
        let details = results[name]!
        let marks = Field.allCases.map { field in
            let ok = passes(field, details, truth)
            if ok { scores[name]![field, default: 0] += 1 }
            return ok ? "✓" : "✗"
        }.joined()
        print("  \(name.padding(toLength: 14, withPad: " ", startingAt: 0)) \(marks)  \(show(details))")
    }
}

print("\nScore out of \(truths.count)   merchant total currency date  all")
for name in pipelines {
    let fields = Field.allCases.map { scores[name]![$0, default: 0] }
    let line = fields.map { String($0).padding(toLength: 8, withPad: " ", startingAt: 0) }.joined()
    print("  \(name.padding(toLength: 14, withPad: " ", startingAt: 0)) \(line) \(fields.reduce(0, +))/\(truths.count * 4)")
}
