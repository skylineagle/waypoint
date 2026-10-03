import SwiftUI

struct DayTimeline: View {
    let entries: [TimelineEntry]
    let stopCount: Int
    let doneIDs: Set<Int>
    let nextID: Int?
    let legs: [Int: TravelLeg]
    let bookings: DayBookings
    let highlightedID: Int?
    let onSelect: (TripStop) -> Void
    let onShowOnMap: (TripStop) -> Void
    let onToggle: ((TripStop) -> Void)?

    var body: some View {
        ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
            Group {
                switch entry {
                case .note(let note):
                    NoteRow(note: note)
                case .stop(let stop, let number):
                    VStack(alignment: .leading, spacing: 6) {
                        if let journey = bookings.journeys[stop.id] {
                            JourneyLegLabel(reservation: journey)
                        } else if number > 1, let leg = legs[stop.id], stop.id != nextID, !doneIDs.contains(stop.id) {
                            TravelLegLabel(leg: leg)
                        }
                        row(stop: stop, number: number)
                    }
                    .id(stop.id)
                    .swipeActions(edge: .leading) { doneAction(stop) }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) { placeActions(stop) }
                    .contextMenu {
                        if let onToggle {
                            let isDone = doneIDs.contains(stop.id)
                            Button(isDone ? "Undo" : "Done", systemImage: isDone ? "arrow.uturn.backward" : "checkmark") { onToggle(stop) }
                        }
                        Button("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill") { Directions.open(to: stop.place) }
                        Button("Show on map", systemImage: "map") { onShowOnMap(stop) }
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 3, leading: 16, bottom: 3, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(TimelineLine(isFirst: index == 0, isLast: index == entries.count - 1))
        }
    }

    @ViewBuilder
    private func doneAction(_ stop: TripStop) -> some View {
        if let onToggle {
            let isDone = doneIDs.contains(stop.id)
            Button(isDone ? "Undo" : "Done", systemImage: isDone ? "arrow.uturn.backward" : "checkmark") { onToggle(stop) }
                .tint(Color.trekSuccess)
        }
    }

    @ViewBuilder
    private func placeActions(_ stop: TripStop) -> some View {
        Button("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill") { Directions.open(to: stop.place) }
            .tint(Color.trekAccent)
        Button("Show on map", systemImage: "map") { onShowOnMap(stop) }
            .tint(Color(hex: 0x111827))
    }

    @ViewBuilder
    private func row(stop: TripStop, number: Int) -> some View {
        if stop.id == nextID {
            HStack(alignment: .top, spacing: 10) {
                TimelineDot(number: number, state: .next, category: stop.place.category)
                    .padding(.top, 14)
                UpNextCard(stop: stop, number: number, total: stopCount, leg: legs[stop.id], booking: bookings.stopBookings[stop.id]) { onToggle?(stop) }
                    .onTapGesture { onSelect(stop) }
            }
        } else {
            StopRow(stop: stop, number: number, booking: bookings.stopBookings[stop.id], state: doneIDs.contains(stop.id) ? .done : .upcoming, isHighlighted: stop.id == highlightedID)
                .onTapGesture { onSelect(stop) }
        }
    }
}
