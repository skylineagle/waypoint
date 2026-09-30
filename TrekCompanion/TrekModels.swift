import Foundation

struct Trip: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let currency: String
    let startDate: String?
    let endDate: String?
    var coverImage: String? = nil
}

extension Trip {
    var isHappeningNow: Bool {
        guard let startDate, let endDate else { return false }
        return (startDate...endDate).contains(ExpenseDate.today)
    }

    var dayProgress: String? {
        guard isHappeningNow, let start = ExpenseDate.date(from: startDate), let end = ExpenseDate.date(from: endDate) else { return nil }
        let calendar = Calendar.current
        let current = calendar.dateComponents([.day], from: start, to: calendar.startOfDay(for: ExpenseDate.now)).day ?? 0
        let length = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return "Day \(current + 1) of \(length + 1)"
    }

    var dateRange: String? {
        guard let start = ExpenseDate.date(from: startDate), let end = ExpenseDate.date(from: endDate) else { return nil }
        let style = Date.FormatStyle.dateTime.month(.abbreviated).day()
        return "\(start.formatted(style)) – \(end.formatted(style))"
    }
}

struct BudgetItem: Codable, Identifiable, Hashable {
    let id: Int
    var name: String
    var category: String
    var totalPrice: Double
    var currency: String?
    var exchangeRate: Double?
    var note: String?
    var expenseDate: String?
    var payers: [Payer]?
    var members: [Member]?
    var receipts: [Receipt]?

    struct Receipt: Codable, Hashable {
        let id: Int
    }

    struct Payer: Codable, Hashable {
        let userId: Int
        let amount: Double
    }

    struct Member: Codable, Hashable {
        let userId: Int
    }

    var hasPayer: Bool {
        (payers ?? []).contains { $0.amount != 0 }
    }

    var costCategory: CostCategory {
        CostCategory(stored: category)
    }

    var isFromApplePay: Bool {
        note == ExpenseInput.applePayNote
    }
}

struct ExpenseInput: Encodable {
    static let applePayNote = "Apple Pay"

    struct PayerInput: Encodable {
        let userId: Int
        let amount: Double
    }

    var name: String
    var category: String?
    var totalPrice: Double
    var currency: String?
    var note: String?
    var expenseDate: String?
    var payers: [PayerInput]?
    var memberIds: [Int]?
}

struct TripMember: Decodable, Identifiable, Hashable {
    let id: Int
    let username: String
}

struct TrekError: LocalizedError, CustomLocalizedStringResourceConvertible {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? { message }
    var localizedStringResource: LocalizedStringResource { "\(message)" }
}

enum ExpenseDate {
    static let format = Date.ISO8601FormatStyle(timeZone: .current).year().month().day()

    static var now: Date {
        #if DEBUG
        if let override = UserDefaults.standard.string(forKey: "TodayDate"), let date = try? format.parse(override) {
            return date.addingTimeInterval(10 * 3600)
        }
        #endif
        return .now
    }

    static var today: String { format.format(now) }

    static func date(from value: String?) -> Date? {
        value.flatMap { try? format.parse($0) }
    }
}
