import ImageIO
import Vision

enum ReceiptDetector {
    private static let documentLabels: Set<String> = ["receipt", "printed_page"]

    static func details(of file: URL) async -> ReceiptDetails? {
        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 2000,
        ] as CFDictionary
        guard let source = CGImageSourceCreateWithURL(file as CFURL, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options),
              await looksLikeDocument(image) else { return nil }
        let details = await ReceiptParser.details(of: image)
        return details.total == nil ? nil : details
    }

    private static func looksLikeDocument(_ image: CGImage) async -> Bool {
        guard let labels = try? await ClassifyImageRequest().perform(on: image) else { return true }
        // ponytail: fixed confidence cut, tune from real misses before adding a custom model
        return labels.contains { documentLabels.contains($0.identifier) && $0.confidence > 0.2 }
    }
}
