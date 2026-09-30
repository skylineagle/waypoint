import SwiftUI

struct DayStrip: View {
    let days: [TripDay]
    let segments: [TripSegment]
    let todayID: Int?
    let selectedID: Int?
    let daysUntilStart: Int?
    let onSelect: (TripDay) -> Void
    let onOverscrollStart: () -> Void

    private static let upcomingID = -1

    private var anchorID: Int? {
        selectedID ?? todayID ?? (daysUntilStart == nil ? nil : Self.upcomingID)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    if let daysUntilStart, selectedID == nil {
                        Color.clear
                            .containerRelativeFrame(.horizontal) { width, _ in max((width - 120) / 2 - 32, 0) }
                            .frame(height: 1)
                        UpcomingChip(daysUntil: daysUntilStart)
                            .id(Self.upcomingID)
                            .transition(.opacity)
                    }
                    ForEach(Array(days.enumerated()), id: \.element.id) { index, day in
                        DayChip(day: day, number: index + 1, segment: segments.first { $0.covers(dayNumber: index + 1) }, isSelected: day.id == selectedID, isToday: day.id == todayID) {
                            onSelect(day)
                        }
                        .id(day.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            .scrollIndicators(.hidden)
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentOffset.x + geometry.contentInsets.leading < -70
            } action: { _, isPulled in
                if isPulled, selectedID != nil { onOverscrollStart() }
            }
            .sensoryFeedback(.impact, trigger: selectedID == nil)
            .onAppear { proxy.scrollTo(anchorID, anchor: .center) }
            .onChange(of: selectedID) {
                withAnimation(.smooth) { proxy.scrollTo(anchorID, anchor: .center) }
            }
        }
    }
}
