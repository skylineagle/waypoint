import SwiftUI

struct ExpenseRow: View {
    let item: BudgetItem
    let converter: CurrencyConverter

    private var itemCurrency: String {
        item.currency ?? converter.tripCurrency
    }

    private var details: String {
        item.isFromApplePay ? "\(item.costCategory.label) · Apple Pay" : item.costCategory.label
    }

    var body: some View {
        HStack(spacing: 11) {
            CategoryTile(category: item.costCategory)
            VStack(alignment: .leading, spacing: 1) {
                Text(item.name)
                    .font(.poppins(14, .semibold))
                    .foregroundStyle(Color.trekText)
                    .lineLimit(2)
                Text(details)
                    .font(.poppins(11.5, relativeTo: .caption))
                    .foregroundStyle(Color.trekMuted)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 1) {
                Text(converter.displayAmount(of: item).map { $0.money(converter.displayCurrency) } ?? item.totalPrice.money(itemCurrency))
                    .font(.poppins(14, .semibold))
                    .foregroundStyle(Color.trekText)
                if itemCurrency.uppercased() != converter.displayCurrency, converter.displayAmount(of: item) != nil {
                    Text(item.totalPrice.money(itemCurrency))
                        .font(.poppins(11, relativeTo: .caption2))
                        .foregroundStyle(Color.trekMuted)
                }
            }
            .monospacedDigit()
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
