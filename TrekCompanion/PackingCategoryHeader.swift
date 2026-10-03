import SwiftUI

struct PackingCategoryHeader: View {
    let category: PackingCategory
    let isCollapsed: Bool
    let onToggle: () -> Void

    private var style: PackingCategoryStyle { PackingCategoryStyle(category: category.name) }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                Image(systemName: style.symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(style.color)
                    .frame(width: 30, height: 30)
                    .background(style.color.opacity(0.2), in: .rect(cornerRadius: 8))
                Text(category.name)
                    .font(.poppins(17, .bold, relativeTo: .headline))
                    .foregroundStyle(Color.trekText)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(category.leftCount == 0 ? "Packed" : "\(category.leftCount) left")
                    .font(.poppins(13, relativeTo: .footnote))
                    .foregroundStyle(Color.trekMuted)
                    .contentTransition(.numericText())
                PackingProgressRing(packed: category.packedCount, total: category.items.count, tint: style.color)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.trekFaint)
                    .rotationEffect(.degrees(isCollapsed ? -90 : 0))
            }
            .environment(\.layoutDirection, category.name.isRightToLeft ? .rightToLeft : .leftToRight)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .textCase(nil)
        .padding(.bottom, 2)
        .accessibilityLabel("\(category.name), \(category.packedCount) of \(category.items.count) packed")
        .accessibilityHint(isCollapsed ? "Expands the category" : "Collapses the category")
    }
}
