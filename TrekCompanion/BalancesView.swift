import SwiftUI

struct BalancesView: View {
    let model: CostsModel

    var body: some View {
        if let settlement = model.settlement, model.isShared {
            VStack(spacing: 10) {
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
}
