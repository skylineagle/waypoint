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

let oct7 = try decoder.decode(TripDay.self, from: Data(#"""
{
  "id": 3, "date": "2026-10-07",
  "assignments": [
    {"id": 28, "order_index": 0, "place": {"id": 1, "name": "Senso-ji", "lat": 35.7147, "lng": 139.7966}},
    {"id": 32, "order_index": 1, "place": {"id": 2, "name": "Nakamise", "lat": 35.7118, "lng": 139.7964}},
    {"id": 33, "order_index": 2, "place": {"id": 3, "name": "Gyukatsu", "lat": 35.7107, "lng": 139.7959}},
    {"id": 34, "order_index": 3, "place": {"id": 4, "name": "Ueno Park", "lat": 35.7147, "lng": 139.7734}}
  ]
}
"""#.utf8))
func train(id: Int, time: String, position: Double, from: (Double, Double), to: (Double, Double)) throws -> Reservation {
    try decoder.decode(Reservation.self, from: Data("""
    {"id": \(id), "trip_id": 1, "title": "Train", "type": "train", "reservation_time": "\(time)", "day_id": 3,
     "day_plan_position": 9, "day_positions": {"3": \(position)},
     "endpoints": [{"role": "from", "name": "A", "lat": \(from.0), "lng": \(from.1)}, {"role": "to", "name": "B", "lat": \(to.0), "lng": \(to.1)}]}
    """.utf8))
}
let hotelToAsakusa = try train(id: 53, time: "2026-10-07T09:41", position: -0.5, from: (35.6694, 139.7673), to: (35.7107, 139.7973))
let asakusaToUeno = try train(id: 55, time: "13:17", position: 2.5, from: (35.7108, 139.7975), to: (35.7116, 139.7761))
let bookings = DayBookings(day: oct7, bookings: [hotelToAsakusa, asakusaToUeno])
assert(bookings.journeys[28]?.id == 53)
assert(bookings.journeys[34]?.id == 55)
assert(bookings.journeys.count == 2 && bookings.loose.isEmpty)
print("Itinerary ordering checks passed")
