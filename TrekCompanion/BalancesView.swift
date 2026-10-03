import SwiftUI

struct BalancesView: View {
    let model: CostsModel

    var body: some View {
        if let settlement = model.settlement, model.isShared {
            VStack(spacing: 10) {
                summary
                SettleUpCard(model: model, flows: settlement.flows)
                BalancesCard(model: model, balances: settlement.balances)
                FinalBudgetCard(model: model, budgets: settlement.finalBudgets)
            }
        } else {
            Text("Balances appear when the trip is shared with others.")
                .font(.poppins(13))
                .foregroundStyle(Color.trekMuted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 120)
        }
    }

    private var summary: some View {
        HStack(spacing: 10) {
            amount("You owe", model.youOwe, tint: model.youOwe > 0.005 ? .trekDanger : .trekText)
            amount("You're owed", model.youreOwed, tint: model.youreOwed > 0.005 ? .trekSuccess : .trekText)
        }
    }

    private func amount(_ title: String, _ value: Double, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            CardCaption(text: title)
            Text(value.money(model.converter.displayCurrency, fractionDigits: 0...0))
                .font(.poppins(20, .bold, relativeTo: .title3))
                .foregroundStyle(tint)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .trekCard()
        .accessibilityElement(children: .combine)
    }
}
