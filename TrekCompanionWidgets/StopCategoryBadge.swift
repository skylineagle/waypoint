import SwiftUI

struct StopCategoryBadge: View {
    let category: StopCategory
    var size: CGFloat = 30

    var body: some View {
        Image(systemName: category.symbol)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(category.tint)
            .frame(width: size, height: size)
            .background(category.tint.opacity(0.18), in: .circle)
    }
}
