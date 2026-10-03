import SwiftUI

struct CostsInsightsView: View {
    let model: CostsModel
    let onSelectCategory: (CostCategory) -> Void

    var body: some View {
        VStack(spacing: 10) {
            if model.total == nil {
                Text("Exchange rates are unavailable. Pull to refresh to try again.")
                    .font(.poppins(13))
                    .foregroundStyle(Color.trekMuted)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else if model.categoryTotals.isEmpty {
                Text("Insights appear once you have expenses.")
                    .font(.poppins(13))
                    .foregroundStyle(Color.trekMuted)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                CategoryDonutCard(
                    totals: model.categoryTotals,
                    total: model.total ?? 0,
                    currency: model.converter.displayCurrency,
                    onSelect: onSelectCategory
                )
                if model.dailyTotals.contains(where: { $0.amount > 0 }) {
                    DailySpendCard(days: model.dailyTotals, currency: model.converter.displayCurrency)
                }
            }
        }
    }
}
