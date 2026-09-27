import SwiftUI

struct ExpenseDayHeader: View {
    let day: ExpenseDay
    let currency: String

    private var title: String {
        guard let date = ExpenseDate.date(from: day.date) else { return "No date" }
        if day.date == ExpenseDate.today { return "Today" }
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: ExpenseDate.now), day.date == ExpenseDate.format.format(yesterday) {
            return "Yesterday"
        }
        return date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }

    var body: some View {
        HStack {
            Text(title.uppercased())
            Spacer()
            Text(day.total.money(currency, fractionDigits: 0...0))
                .monospacedDigit()
        }
        .font(.poppins(11, .semibold, relativeTo: .caption))
        .tracking(0.5)
        .foregroundStyle(Color.trekMuted)
        .textCase(nil)
    }
}
