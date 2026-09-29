import UIKit
import Vision

enum ReceiptReader {
    static func details(of image: UIImage) async -> ReceiptDetails {
        guard let cgImage = image.cgImage else { return ReceiptDetails() }
        var request = RecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.automaticallyDetectsLanguage = true
        let observations = (try? await request.perform(on: cgImage)) ?? []
        let lines = observations.compactMap { $0.topCandidates(1).first?.string }
        return ReceiptText.details(from: lines)
    }
}
