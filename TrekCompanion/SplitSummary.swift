import SwiftUI

struct SplitSummary: View {
    let model: CostsModel
    let onShowUnpaid: () -> Void

    private var currency: String { model.converter.displayCurrency }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 16) {
                SplitFigure(
                    title: "You owe",
                    amount: model.youOwe.money(currency),
                    footnote: model.youOwe > 0.5 ? "To \(names(model.owedTo))" : "All settled up",
                    tint: model.youOwe > 0.5 ? .trekDanger : .trekText
                )
                SplitFigure(
                    title: "You're owed",
                    amount: model.youreOwed.money(currency),
                    footnote: model.youreOwed > 0.5 ? "From \(names(model.owedBy))" : "Nothing owed",
                    tint: model.youreOwed > 0.5 ? .trekSuccess : .trekText
                )
            }
            if !model.unpaidItems.isEmpty {
                Button(action: onShowUnpaid) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(Color.trekWarning)
                        Text("\(model.unpaidItems.count) expenses need a payer")
                            .foregroundStyle(Color.trekTextSecondary)
                        Spacer(minLength: 8)
                        Text(model.unpaidTotal.money(currency))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.trekWarning)
                            .monospacedDigit()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.trekFaint)
                    }
                    .font(.poppins(13, relativeTo: .subheadline))
                    .contentShape(.rect)
                }
                .buttonStyle(.borderless)
                .accessibilityHint("Shows the expenses so you can set who paid")
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }

    private func names(_ people: [Settlement.Person]) -> String {
        people.map(\.username).joined(separator: ", ")
    }
}
