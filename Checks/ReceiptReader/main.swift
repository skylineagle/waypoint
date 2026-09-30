import Foundation
import ImageIO
import Vision

let paths = CommandLine.arguments.dropFirst()
guard !paths.isEmpty else {
    print("usage: scripts/read-receipt.sh <image> [image...]")
    exit(1)
}
print("model available:", ReceiptParser.isAvailable)
for path in paths {
    print("== \(path)")
    guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else {
        print("!! can't read image")
        continue
    }
    var request = RecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.automaticallyDetectsLanguage = true
    let rows = ReceiptRows.rows(from: try await request.perform(on: image))
    rows.enumerated().forEach { print(String(format: "%3d", $0.offset), $0.element.text) }
    let details = await ReceiptParser.details(from: rows)
    print("-> merchant:", details.merchant ?? "-")
    print("-> total:   ", details.total.map { "\($0)" } ?? "-")
    print("-> currency:", details.currency ?? "-")
    print("-> date:    ", details.date.map { $0.formatted(date: .abbreviated, time: .omitted) } ?? "-")
}
