import SwiftUI

struct FinalBudgetCard: View {
    let model: CostsModel
    let budgets: [Settlement.FinalBudget]
    @State private var expandedID: Int?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var currency: String { model.converter.displayCurrency }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            CardCaption(text: "Final budget")
                .padding(.bottom, 6)
            ForEach(budgets) { budget in
                VStack(spacing: 8) {
                    Button {
                        withAnimation(.snappy) { expandedID = expandedID == budget.userId ? nil : budget.userId }
                    } label: {
                        HStack(spacing: 10) {
                            MemberAvatar(userID: budget.userId, name: model.name(of: budget.userId, username: budget.username), size: 32)
                            Text(model.name(of: budget.userId, username: budget.username))
                                .font(.poppins(14, .semibold))
                            Spacer()
                            Text(budget.final.money(currency))
                                .font(.poppins(14, .bold))
                                .monospacedDigit()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.trekFaint)
                                .rotationEffect(.degrees(expandedID == budget.userId ? 180 : 0))
                        }
                        .foregroundStyle(Color.trekText)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityValue(expandedID == budget.userId ? "Expanded" : "Collapsed")

                    if expandedID == budget.userId {
                        VStack(spacing: 6) {
                            line("Paid for the group", budget.expenses)
                            line("Reimbursed", -budget.reimbursed)
                            line("Still to settle", -budget.pending)
                            Divider().overlay(Color.trekDivider)
                            line("Trip cost", budget.final, isTotal: true)
                        }
                        .padding(.leading, 42)
                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .padding(13)
        .trekCard()
    }

    private func line(_ label: String, _ amount: Double, isTotal: Bool = false) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text((abs(amount) < 0.005 ? 0 : amount).money(currency)).monospacedDigit()
        }
        .font(.poppins(12.5, isTotal ? .semibold : .regular, relativeTo: .footnote))
        .foregroundStyle(isTotal ? Color.trekText : Color.trekMuted)
    }
}
