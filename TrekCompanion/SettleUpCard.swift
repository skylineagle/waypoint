import SwiftUI

struct SettleUpCard: View {
    let model: CostsModel
    let flows: [Settlement.Flow]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CardCaption(text: "Settle up")
            if flows.isEmpty {
                HStack(spacing: 10) {
                    SplitIcon(symbol: "checkmark", tint: .trekSuccess)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Everyone is square")
                            .font(.poppins(13, .semibold, relativeTo: .subheadline))
                            .foregroundStyle(Color.trekText)
                        Text("Nothing outstanding between travelers")
                            .font(.poppins(11, relativeTo: .caption2))
                            .foregroundStyle(Color.trekMuted)
                    }
                }
            } else {
                ForEach(flows) { flow in
                    HStack(spacing: 8) {
                        MemberAvatar(userID: flow.from.userId, name: model.name(of: flow.from.userId, username: flow.from.username), size: 24)
                        Text(model.name(of: flow.from.userId, username: flow.from.username))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.trekFaint)
                            .accessibilityLabel("pays")
                        MemberAvatar(userID: flow.to.userId, name: model.name(of: flow.to.userId, username: flow.to.username), size: 24)
                        Text(model.name(of: flow.to.userId, username: flow.to.username))
                        Spacer(minLength: 6)
                        Text(flow.amount.money(model.converter.displayCurrency))
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                    .font(.poppins(13, .semibold, relativeTo: .subheadline))
                    .foregroundStyle(Color.trekText)
                    .lineLimit(1)
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .trekCard()
    }
}
