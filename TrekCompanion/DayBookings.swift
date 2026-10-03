import CoreLocation

struct DayBookings {
    private(set) var journeys: [Int: Reservation] = [:]
    private(set) var stopBookings: [Int: Reservation] = [:]
    private(set) var loose: [Reservation] = []

    private static let arrivalRadius: CLLocationDistance = 2000

    init(day: TripDay, bookings: [Reservation]) {
        let stops = day.stops
        for booking in bookings {
            if booking.isTransport, let stop = Self.arrivalStop(of: booking, on: day), journeys[stop.id] == nil {
                journeys[stop.id] = booking
            } else if !booking.isTransport, let stop = stops.first(where: { $0.id == booking.assignmentId || $0.place.id == booking.placeId }), stopBookings[stop.id] == nil {
                stopBookings[stop.id] = booking
            } else {
                loose.append(booking)
            }
        }
    }

    private static func arrivalStop(of booking: Reservation, on day: TripDay) -> TripStop? {
        if let position = booking.position(on: day.id) {
            return day.positionedStops.first { $0.position > position }?.stop
        }
        let candidates = day.stops.dropFirst()
        if let arrival = booking.arrival {
            let target = CLLocation(latitude: arrival.lat, longitude: arrival.lng)
            return candidates.first { stop in
                guard let coordinate = stop.place.coordinate else { return false }
                return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).distance(from: target) < arrivalRadius
            }
        }
        guard let time = booking.time else { return nil }
        return candidates.first { ($0.assignmentTime ?? "") > time }
    }
}
