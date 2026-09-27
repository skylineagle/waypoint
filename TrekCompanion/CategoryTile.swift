import SwiftUI

struct CategoryTile: View {
    let category: CostCategory
    var size: CGFloat = 34

    var body: some View {
        Image(systemName: category.symbol)
            .font(.system(size: size * 0.44, weight: .semibold))
            .foregroundStyle(category.color)
            .frame(width: size, height: size)
            .background(category.color.opacity(0.12), in: .rect(cornerRadius: size * 0.3))
            .accessibilityHidden(true)
    }
}
