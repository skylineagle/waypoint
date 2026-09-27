import Charts
import SwiftUI

struct CategoryDonutCard: View {
    let totals: [CategoryTotal]
    let total: Double
    let currency: String
    let onSelect: (CostCategory) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CardCaption(text: "By category")
            HStack(spacing: 16) {
                Chart(totals) { slice in
                    SectorMark(angle: .value("Amount", slice.amount), innerRadius: .ratio(0.64), angularInset: 1.5)
                        .cornerRadius(3)
                        .foregroundStyle(slice.category.color)
                }
                .chartLegend(.hidden)
                .frame(width: 128, height: 128)
                .overlay {
                    VStack(spacing: 0) {
                        Text(total.formatted(.currency(code: currency).notation(.compactName)))
                            .font(.poppins(15, .bold, relativeTo: .headline))
                            .foregroundStyle(Color.trekText)
                        Text("\(totals.count) categories")
                            .font(.poppins(10, relativeTo: .caption2))
                            .foregroundStyle(Color.trekMuted)
                    }
                }
                .accessibilityHidden(true)

                VStack(spacing: 2) {
                    ForEach(totals) { slice in
                        Button {
                            onSelect(slice.category)
                        } label: {
                            legendRow(slice)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(slice.category.label), \(slice.amount.money(currency)), \(slice.share.formatted(.percent.precision(.fractionLength(0))))")
                        .accessibilityHint("Shows these expenses")
                    }
                }
            }
        }
        .padding(13)
        .background(Color.trekCard, in: .rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.trekBorder))
    }

    private func legendRow(_ slice: CategoryTotal) -> some View {
        HStack(spacing: 7) {
            Circle().fill(slice.category.color).frame(width: 8, height: 8)
            Text(slice.category.label)
                .foregroundStyle(Color.trekTextSecondary)
                .lineLimit(1)
            Spacer(minLength: 4)
            Text(slice.share.formatted(.percent.precision(.fractionLength(0))))
                .foregroundStyle(Color.trekMuted)
                .monospacedDigit()
        }
        .font(.poppins(12, relativeTo: .caption))
        .padding(.vertical, 3)
        .contentShape(.rect)
    }
}
