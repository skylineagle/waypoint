import Charts
import SwiftUI

struct DailySpendCard: View {
    let days: [DailyTotal]
    let currency: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CardCaption(text: "Per day")
            Chart(days) { day in
                BarMark(x: .value("Day", day.date, unit: .day), y: .value("Spent", day.amount))
                    .cornerRadius(4)
                    .foregroundStyle(day.isToday ? Color.trekSuccess : Color.trekAccent)
                    .accessibilityLabel(day.date.formatted(.dateTime.month().day()))
                    .accessibilityValue(day.amount.money(currency))
            }
            .chartYAxis {
                AxisMarks(position: .trailing) { value in
                    AxisGridLine().foregroundStyle(Color.trekBorder)
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(amount.formatted(.currency(code: currency).notation(.compactName)))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: max(days.count / 6, 1))) {
                    AxisValueLabel(format: .dateTime.day())
                }
            }
            .font(.poppins(10, relativeTo: .caption2))
            .foregroundStyle(Color.trekMuted)
            .frame(height: 140)
        }
        .padding(13)
        .background(Color.trekCard, in: .rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.trekBorder))
    }
}
