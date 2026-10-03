import CoreSpotlight
import UniformTypeIdentifiers

enum SpotlightIndex {
    private static let stopPrefix = "stop"
    private static let bookingPrefix = "booking"

    enum Target: Equatable {
        case stop(dayID: Int, stopID: Int)
        case booking(id: Int)
    }

    static func update(trip: Trip, days: [TripDay], reservations: [Reservation]) async {
        let stops = days.enumerated().flatMap { index, day in
            day.stops.map { item(for: $0, on: day, number: index + 1, in: trip) }
        }
        let bookings = reservations.map { item(for: $0, in: trip) }
        let index = CSSearchableIndex.default()
        try? await index.deleteAllSearchableItems()
        try? await index.indexSearchableItems(stops + bookings)
    }

    static func clear() {
        CSSearchableIndex.default().deleteAllSearchableItems()
    }

    static func target(of activity: NSUserActivity) -> Target? {
        guard let identifier = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return nil }
        let parts = identifier.split(separator: "/").compactMap { Int($0) }
        if identifier.hasPrefix(stopPrefix), parts.count == 2 { return .stop(dayID: parts[0], stopID: parts[1]) }
        if identifier.hasPrefix(bookingPrefix), parts.count == 1 { return .booking(id: parts[0]) }
        return nil
    }

    private static func item(for stop: TripStop, on day: TripDay, number: Int, in trip: Trip) -> CSSearchableItem {
        let attributes = CSSearchableItemAttributeSet(contentType: .content)
        attributes.title = stop.place.name
        attributes.contentDescription = [stop.place.address, "Day \(number) · \(trip.title)"].compactMap(\.self).joined(separator: "\n")
        attributes.latitude = stop.place.lat.map { NSNumber(value: $0) }
        attributes.longitude = stop.place.lng.map { NSNumber(value: $0) }
        attributes.supportsNavigation = stop.place.coordinate != nil ? true : nil
        attributes.keywords = [trip.title, day.title].compactMap(\.self)
        return CSSearchableItem(uniqueIdentifier: "\(stopPrefix)/\(day.id)/\(stop.id)", domainIdentifier: stopPrefix, attributeSet: attributes)
    }

    private static func item(for reservation: Reservation, in trip: Trip) -> CSSearchableItem {
        let attributes = CSSearchableItemAttributeSet(contentType: .content)
        attributes.title = reservation.title
        let confirmation = reservation.confirmationNumber.map { "Confirmation \($0)" }
        attributes.contentDescription = [confirmation, reservation.location, trip.title]
            .compactMap(\.self).joined(separator: "\n")
        attributes.startDate = reservation.startDate
        attributes.endDate = reservation.endDate
        attributes.keywords = [trip.title, reservation.type, reservation.confirmationNumber].compactMap(\.self)
        return CSSearchableItem(uniqueIdentifier: "\(bookingPrefix)/\(reservation.id)", domainIdentifier: bookingPrefix, attributeSet: attributes)
    }
}
