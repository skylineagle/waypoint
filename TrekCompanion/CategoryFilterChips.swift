import SwiftUI

struct CategoryFilterChips: View {
    let categories: [CostCategory]
    @Binding var selection: CostCategory?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    chip(title: "All", color: nil, isSelected: selection == nil) { selection = nil }
                    ForEach(categories) { category in
                        chip(title: category.label, color: category.color, isSelected: selection == category) {
                            selection = selection == category ? nil : category
                        }
                        .id(category)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onAppear { proxy.scrollTo(selection, anchor: .center) }
            .onChange(of: selection) { _, category in
                withAnimation { proxy.scrollTo(category, anchor: .center) }
            }
        }
    }

    private func chip(title: String, color: Color?, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let color {
                    Circle().fill(color).frame(width: 7, height: 7)
                }
                Text(title)
            }
            .font(.poppins(12, .semibold, relativeTo: .caption))
            .foregroundStyle(isSelected ? Color.trekAccentText : Color.trekTextSecondary)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(isSelected ? Color.trekAccent : Color.trekCard, in: .capsule)
            .overlay(Capsule().strokeBorder(isSelected ? Color.clear : Color.trekBorder))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
