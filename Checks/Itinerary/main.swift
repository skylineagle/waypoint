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

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
let checkInDay = try decoder.decode(TripDay.self, from: Data(#"""
{
  "id": 10, "date": "2026-10-14",
  "assignments": [
    {"id": 42, "order_index": 0, "accommodation_id": 3,
     "place": {"id": 173, "name": "Cross Hotel Kyoto"}},
    {"id": 26, "order_index": 1, "accommodation_id": null,
     "place": {"id": 165, "name": "teamLab"}},
    {"id": 27, "order_index": 2,
     "place": {"id": 166, "name": "Pontocho"}},
    {"id": 44, "order_index": 3,
     "place": {"id": 231, "name": "Bar"}},
    {"id": 45, "order_index": 4,
     "place": {"id": 173, "name": "Cross Hotel Kyoto"}}
  ],
  "notes_items": [
    {"id": 15, "text": "Leave Osaka", "sort_order": 0},
    {"id": 6, "text": "Check in", "sort_order": 0.5},
    {"id": 7, "text": "After teamLab", "sort_order": 1.5}
  ]
}
"""#.utf8))
assert(checkInDay.stops.map(\.id) == [26, 27, 44, 45])
assert(checkInDay.timeline.map(\.id) == ["note-15", "note-6", "stop-26", "note-7", "stop-27", "stop-44", "stop-45"])
assert(checkInDay.timeline.compactMap { entry -> Int? in
    guard case .stop(_, let number) = entry else { return nil }
    return number
} == [1, 2, 3, 4])
let onlyStay = TripDay(id: 11, date: nil, title: nil, assignments: [checkInDay.assignments![0]], notesItems: checkInDay.notesItems)
assert(onlyStay.stops.isEmpty)
assert(onlyStay.timeline.count == 3)
let stay = try decoder.decode(Stay.self, from: Data(#"{"id":3,"start_day_id":10,"end_day_id":14,"check_in":"15:00"}"#.utf8))
assert(stay.startDayId == checkInDay.id && stay.checkIn == "15:00")
print("Itinerary ordering checks passed")
