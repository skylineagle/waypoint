import SwiftUI

struct CategoryGrid: View {
    @Binding var selection: CostCategory

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 7) {
            ForEach(CostCategory.allCases) { category in
                Button {
                    selection = category
                } label: {
                    VStack(spacing: 5) {
                        CategoryTile(category: category, size: 30)
                        Text(category.label)
                            .font(.poppins(10, relativeTo: .caption2))
                            .foregroundStyle(Color.trekTextSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(Color.trekCard, in: .rect(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(selection == category ? category.color : Color.trekBorder, lineWidth: selection == category ? 2 : 1)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(category.label)
                .accessibilityAddTraits(selection == category ? .isSelected : [])
            }
        }
    }
}
