import SwiftUI

struct TodaySpendCard: View {
    let costs: CostsModel
    let onAdd: () -> Void

    private var currency: String { costs.converter.displayCurrency }

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                CardCaption(text: "Spent today")
                Text(costs.todayTotal.money(currency, fractionDigits: 0...0))
                    .font(.poppins(18, .bold, relativeTo: .title3))
                    .foregroundStyle(Color.trekText)
                    .monospacedDigit()
                if costs.hasStarted {
                    Text("avg \(costs.dailyAverage.money(currency, fractionDigits: 0...0)) / trip day")
                        .font(.poppins(11, relativeTo: .caption2))
                        .foregroundStyle(Color.trekMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .trekCard()
            .accessibilityElement(children: .combine)

            Button(action: onAdd) {
                Label("Add expense", systemImage: "plus")
                    .font(.poppins(13.5, .semibold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.trekText)
            .trekCard()
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
