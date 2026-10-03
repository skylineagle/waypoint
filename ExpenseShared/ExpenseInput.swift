import Foundation

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
