import Foundation

extension Double {
    func money(_ currency: String, fractionDigits: ClosedRange<Int> = 0...2) -> String {
        formatted(.currency(code: currency).precision(.fractionLength(fractionDigits)))
    }
}

extension Optional where Wrapped == Double {
    func money(_ currency: String, fractionDigits: ClosedRange<Int> = 0...2) -> String {
        map { $0.money(currency, fractionDigits: fractionDigits) } ?? "Unavailable"
    }
}
