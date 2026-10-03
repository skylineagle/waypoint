import Foundation
import FoundationModels

enum ReceiptModel {
    @Generable
    struct Extraction {
        @Guide(description: "Store or restaurant name exactly as printed, usually near the top. Not a bank, card or document title.")
        var merchant: String?
        @Guide(description: "The final amount the customer paid, printed next to a word like TOTAL, SUMME, SUMA, TOTALE, 합계 or 總計. Never a subtotal, tax, discount, cash handed over, or change.")
        var total: Double?
        @Guide(description: "ISO 4217 code, only when a currency code or symbol is printed on the receipt.")
        var currency: String?
        @Guide(description: "Purchase date as yyyy-MM-dd, only when a date is printed.")
        var date: String?
    }

    static let instructions = """
        You read receipts that were scanned with OCR. Each line of input is one printed row, with columns separated by two spaces. \
        Extract only what is printed. Leave a field empty when you are not sure.
        """

    static var isAvailable: Bool {
        if case .available = SystemLanguageModel.default.availability { true } else { false }
    }

    static func details(from rows: [ReceiptRow], now: Date = .now) async -> ReceiptDetails {
        let text = rows.map(\.text).joined(separator: "\n")
        guard let response = try? await LanguageModelSession(instructions: instructions)
            .respond(to: text, generating: Extraction.self, options: GenerationOptions(samplingMode: .greedy))
        else { return ReceiptDetails() }
        let extraction = response.content
        return ReceiptDetails(
            merchant: extraction.merchant.flatMap { text.localizedCaseInsensitiveContains($0) ? $0 : nil },
            total: extraction.total.flatMap { ReceiptRules.isPlausibleTotal($0, in: rows) ? $0 : nil },
            currency: extraction.currency.flatMap(ReceiptRules.currencyCode),
            date: extraction.date.flatMap(parsedDate).flatMap { $0 <= now ? $0 : nil }
        )
    }

    private static func parsedDate(_ text: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: text)
    }
}
