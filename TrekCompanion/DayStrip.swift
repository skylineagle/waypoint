import SwiftUI

struct DayStrip: View {
    let days: [TripDay]
    let todayID: Int?
    let selectedID: Int?
    let onSelect: (TripDay) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                GlassEffectContainer(spacing: 8) {
                    HStack(spacing: 8) {
                        ForEach(Array(days.enumerated()), id: \.element.id) { index, day in
                            DayChip(day: day, number: index + 1, isSelected: day.id == selectedID, isToday: day.id == todayID) {
                                onSelect(day)
                            }
                            .id(day.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
            }
            .scrollIndicators(.hidden)
            .onAppear { proxy.scrollTo(selectedID ?? todayID, anchor: .center) }
            .onChange(of: selectedID) { _, id in
                withAnimation(.smooth) { proxy.scrollTo(id ?? todayID, anchor: .center) }
            }
        }
    }
}
