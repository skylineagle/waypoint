import Foundation
import ImageIO
import Vision

func lines(in path: String) async throws -> [String] {
    guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else { throw CocoaError(.fileReadCorruptFile) }
    var request = RecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.automaticallyDetectsLanguage = true
    return try await request.perform(on: image).compactMap { $0.topCandidates(1).first?.string }
}

let paths = CommandLine.arguments.dropFirst()
guard !paths.isEmpty else {
    print("usage: scripts/read-receipt.sh <image> [image...]")
    exit(1)
}
for path in paths {
    print("== \(path)")
    do {
        let text = try await lines(in: path)
        text.enumerated().forEach { print(String(format: "%3d", $0.offset), $0.element) }
        let details = ReceiptText.details(from: text)
        print("-> merchant:", details.merchant ?? "-")
        print("-> total:   ", details.total.map { "\($0)" } ?? "-")
        print("-> currency:", details.currency ?? "-")
        print("-> date:    ", details.date.map { $0.formatted(date: .abbreviated, time: .omitted) } ?? "-")
    } catch {
        print("!! \(error.localizedDescription)")
    }
}
