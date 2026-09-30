import SwiftUI

struct CategoryFilterChips: View {
    let categories: [CostCategory]
    @Binding var selection: CostCategory?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    FilterChip(title: "All", isSelected: selection == nil) { selection = nil }
                    ForEach(categories) { category in
                        FilterChip(title: category.label, color: category.color, isSelected: selection == category) {
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
}
