import SwiftUI

struct BalancesCard: View {
    let model: CostsModel
    let balances: [Settlement.Balance]

    private var largest: Double {
        max(balances.map { abs($0.balance) }.max() ?? 0, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CardCaption(text: "Balances")
            ForEach(balances) { balance in
                HStack(spacing: 10) {
                    MemberAvatar(userID: balance.userId, name: model.name(of: balance.userId, username: balance.username), size: 32)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(model.name(of: balance.userId, username: balance.username))
                            .font(.poppins(14, .semibold))
                            .foregroundStyle(Color.trekText)
                        BalanceBar(share: balance.balance / largest)
                    }
                    Text(signed(balance.balance))
                        .font(.poppins(14, .bold))
                        .foregroundStyle(balance.balance > 0.005 ? Color.trekSuccess : balance.balance < -0.005 ? Color.trekDanger : Color.trekMuted)
                        .monospacedDigit()
                        .frame(minWidth: 96, alignment: .trailing)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(13)
        .trekCard()
    }

    private func signed(_ amount: Double) -> String {
        let formatted = abs(amount).money(model.converter.displayCurrency)
        return amount > 0.005 ? "+\(formatted)" : amount < -0.005 ? "−\(formatted)" : formatted
    }
}
