import UIKit

enum ReceiptReader {
    static func details(of image: UIImage) async -> ReceiptDetails {
        guard let cgImage = image.cgImage else { return ReceiptDetails() }
        return await ReceiptParser.details(of: cgImage)
    }
}
