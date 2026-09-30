import Foundation

func stop(id: Int, order: Int, time: String?) -> TripStop {
    TripStop(
        id: id,
        orderIndex: order,
        assignmentTime: time,
        notes: nil,
        place: StopPlace(id: id, name: "Stop \(id)", lat: nil, lng: nil, address: nil)
    )
}

let day = TripDay(id: 4, date: "2026-10-08", title: nil, assignments: [
    stop(id: 3, order: 2, time: "08:00"),
    stop(id: 2, order: 1, time: nil),
    stop(id: 1, order: 0, time: "09:00"),
], notesItems: nil)

assert(day.stops.map(\.id) == [1, 2, 3])
assert(day.timeline.map(\.id) == ["stop-1", "stop-2", "stop-3"])
assert(TripDay(id: 5, date: nil, title: nil, assignments: nil, notesItems: nil).stops.isEmpty)
print("Itinerary ordering checks passed")
