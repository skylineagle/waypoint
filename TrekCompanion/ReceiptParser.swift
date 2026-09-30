import CoreGraphics
import Foundation
import Vision

struct ReceiptDetails: Equatable {
    var merchant: String?
    var total: Double?
    var currency: String?
    var date: Date?
}

enum ReceiptParser {
    static let isAvailable = ReceiptModel.isAvailable

    static func details(of image: CGImage, now: Date = .now) async -> ReceiptDetails {
        var request = RecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.automaticallyDetectsLanguage = true
        let observations = (try? await request.perform(on: image)) ?? []
        return await details(from: ReceiptRows.rows(from: observations), now: now)
    }

    static func details(from rows: [ReceiptRow], now: Date = .now) async -> ReceiptDetails {
        let rules = ReceiptRules.details(from: rows, now: now)
        let model = await ReceiptModel.details(from: rows, now: now)
        return ReceiptDetails(
            merchant: model.merchant ?? rules.merchant,
            total: model.total ?? rules.total,
            currency: rules.currency,
            date: rules.date
        )
    }
}
