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
    let onToggle: ((TripStop) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(entries) { entry in
                switch entry {
                case .note(let note):
                    NoteRow(note: note)
                case .stop(let stop, let number):
                    if let journey = bookings.journeys[stop.id] {
                        JourneyLegLabel(reservation: journey)
                    } else if number > 1, let leg = legs[stop.id], stop.id != nextID, !doneIDs.contains(stop.id) {
                        TravelLegLabel(leg: leg)
                    }
                    row(stop: stop, number: number)
                        .id(stop.id)
                }
            }
        }
        .background(alignment: .leading) {
            Rectangle()
                .fill(Color.trekBorder)
                .frame(width: 1.5)
                .padding(.vertical, 18)
                .padding(.leading, 12.25)
        }
        .animation(.snappy, value: doneIDs)
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
            StopRow(stop: stop, number: number, booking: bookings.stopBookings[stop.id], state: doneIDs.contains(stop.id) ? .done : .upcoming, isHighlighted: stop.id == highlightedID, onToggle: onToggle.map { toggle in { toggle(stop) } })
            .onTapGesture { onSelect(stop) }
        }
    }
}
