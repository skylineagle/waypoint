import SwiftUI

struct DayStrip: View {
    let days: [TripDay]
    let segments: [TripSegment]
    let todayID: Int?
    let selectedID: Int?
    let daysUntilStart: Int?
    let onSelect: (TripDay) -> Void
    let onOverscrollStart: () -> Void
    var inset: CGFloat = 16

    private static let upcomingID = -1

    private struct Run: Identifiable {
        let segment: TripSegment?
        var days: [(day: TripDay, number: Int)]

        var id: Int { days[0].day.id }
    }

    private var runs: [Run] {
        days.enumerated().reduce(into: []) { runs, element in
            let number = element.offset + 1
            let segment = segments.first { $0.covers(dayNumber: number) }
            if let last = runs.last, last.segment?.id == segment?.id {
                runs[runs.count - 1].days.append((element.element, number))
            } else {
                runs.append(Run(segment: segment, days: [(element.element, number)]))
            }
        }
    }

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
                    ForEach(runs) { run in
                        HStack(spacing: 8) {
                            ForEach(run.days, id: \.day.id) { item in
                                DayChip(day: item.day, number: item.number, segment: run.segment, isSelected: item.day.id == selectedID, isToday: item.day.id == todayID) {
                                    onSelect(item.day)
                                }
                                .id(item.day.id)
                            }
                        }
                        .padding(.top, 18)
                        .padding(.bottom, 7)
                        .overlay(alignment: .topLeading) {
                            if let segment = run.segment {
                                Text(segment.name)
                                    .font(.poppins(11, .semibold, relativeTo: .caption2))
                                    .foregroundStyle(segment.tint ?? Color.trekMuted)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .padding(.leading, 4)
                                    .accessibilityHidden(true)
                            }
                        }
                        .overlay(alignment: .bottom) {
                            if let tint = run.segment?.tint {
                                Capsule().fill(tint).frame(height: 3).padding(.horizontal, 6)
                            }
                        }
                    }
                }
                .padding(.horizontal, inset)
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
