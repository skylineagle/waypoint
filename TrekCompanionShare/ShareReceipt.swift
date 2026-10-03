import Foundation

struct ShareReceipt: Identifiable {
    let file: URL
    var name: String
    var amount: Double?
    var currency: String?
    var date: Date
    var category: CostCategory
    var isExpense = true
    var id: URL { file }

    static let dayFormat = Date.ISO8601FormatStyle(timeZone: .current).year().month().day()

    var canAdd: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && (amount ?? 0) > 0 }

    func input(meID: Int, memberIDs: [Int]) -> ExpenseInput {
        let amount = amount ?? 0
        let isShared = memberIDs.count > 1
        return ExpenseInput(
            name: name.trimmingCharacters(in: .whitespaces),
            category: category.rawValue,
            totalPrice: amount,
            currency: currency,
            note: nil,
            expenseDate: Self.dayFormat.format(date),
            payers: [ExpenseInput.PayerInput(userId: meID, amount: amount)],
            memberIds: isShared ? memberIDs : nil
        )
    }
}
