import Foundation

enum TripReminderEvents {
    private static let wallClock: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return formatter
    }()

    static func bookings(_ reservations: [Reservation]) -> [ReminderEvent] {
        reservations.compactMap { reservation in
            guard reservation.status != "cancelled", reservation.type != "hotel",
                  let time = reservation.time, let date = moment(reservation.date, time: time)
            else { return nil }
            let verb = reservation.webTab == "transports" ? "Departs" : "Starts"
            let details = ["\(verb) at \(time)", reservation.confirmationNumber.map { "Conf. \($0)" }].compactMap(\.self)
            return ReminderEvent(
                id: "booking-\(reservation.id)",
                moment: reservation.type == "flight" ? .flight : .booking,
                date: date,
                title: reservation.title,
                body: details.joined(separator: " · ")
            )
        }
    }

    static func stays(_ stays: [Stay], days: [TripDay]) -> [ReminderEvent] {
        let dates = Dictionary(days.compactMap { day in day.date.map { (day.id, $0) } }, uniquingKeysWith: { first, _ in first })
        return stays.flatMap { stay -> [ReminderEvent] in
            let name = stay.placeName ?? "your stay"
            var events: [ReminderEvent] = []
            let checkIn = stay.checkIn ?? "15:00"
            if let date = moment(stay.startDayId.flatMap { dates[$0] }, time: checkIn) {
                let body = ["From \(checkIn)", stay.placeAddress].compactMap(\.self).joined(separator: " · ")
                events.append(ReminderEvent(id: "check-in-\(stay.id)", moment: .checkIn, date: date, title: "Check in at \(name)", body: body))
            }
            let checkOut = stay.checkOut ?? "11:00"
            if let date = moment(stay.endDayId.flatMap { dates[$0] }, time: checkOut) {
                events.append(ReminderEvent(id: "check-out-\(stay.id)", moment: .checkOut, date: date, title: "Check out by \(checkOut)", body: name))
            }
            return events
        }
    }

    static func briefs(_ days: [TripDay]) -> [ReminderEvent] {
        days.enumerated().compactMap { index, day in
            guard let first = day.stops.first, let date = ExpenseDate.date(from: day.date) else { return nil }
            let count = day.stops.count
            return ReminderEvent(
                id: "brief-\(day.id)",
                moment: .day,
                date: date,
                title: ["Day \(index + 1)", day.title].compactMap(\.self).joined(separator: " · "),
                body: "\(count) \(count == 1 ? "stop" : "stops") · first up: \(first.place.name)"
            )
        }
    }

    static func countdown(_ trip: Trip, openTodos: Int?) -> [ReminderEvent] {
        guard let start = ExpenseDate.date(from: trip.startDate) else { return [] }
        let todos = openTodos.flatMap { $0 > 0 ? "\($0) \($0 == 1 ? "to-do" : "to-dos") still open" : nil }
        let body = [trip.dateRange, todos].compactMap(\.self).joined(separator: " · ")
        return [ReminderEvent(id: "trip-\(trip.id)", moment: .tripStart, date: start, title: trip.title, body: body)]
    }

    private static func moment(_ day: String?, time: String) -> Date? {
        day.flatMap { wallClock.date(from: "\($0.prefix(10))T\(time.prefix(5))") }
    }
}
