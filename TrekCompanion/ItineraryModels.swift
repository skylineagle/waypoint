import CoreLocation
import Foundation

struct TripDay: Decodable, Identifiable {
    let id: Int
    let date: String?
    let title: String?
    let assignments: [TripStop]?
    let notesItems: [DayNote]?

    var stops: [TripStop] {
        (assignments ?? []).filter { $0.accommodationId == nil }.sorted { $0.orderIndex < $1.orderIndex }
    }
}

struct DayNote: Decodable, Identifiable, Hashable {
    let id: Int
    let text: String
    let time: String?
    let icon: String?
    let sortOrder: Double?
    let color: String?
}

enum TimelineEntry: Identifiable {
    case stop(TripStop, number: Int)
    case note(DayNote)

    var id: String {
        switch self {
        case .stop(let stop, _): "stop-\(stop.id)"
        case .note(let note): "note-\(note.id)"
        }
    }
}

extension TripDay {
    var timeline: [TimelineEntry] {
        let assignments = (assignments ?? []).sorted { $0.orderIndex < $1.orderIndex }
        var number = 0
        let stops = assignments.enumerated().compactMap { index, stop -> (position: Double, entry: TimelineEntry)? in
            guard stop.accommodationId == nil else { return nil }
            number += 1
            return (Double(index), .stop(stop, number: number))
        }
        let notes = (notesItems ?? []).map { (position: $0.sortOrder ?? Double(assignments.count), entry: TimelineEntry.note($0)) }
        return (notes + stops).sorted { $0.position < $1.position }.map(\.entry)
    }
}

struct TripStop: Decodable, Identifiable, Hashable {
    let id: Int
    let orderIndex: Int
    let assignmentTime: String?
    let notes: String?
    let place: StopPlace
    var accommodationId: Int? = nil
}

struct StopPlace: Decodable, Hashable {
    let id: Int
    let name: String
    let lat: Double?
    let lng: Double?
    let address: String?
    var imageUrl: String? = nil
    var googlePlaceId: String? = nil
    var osmId: String? = nil
    var category: StopCategory? = nil

    var coordinate: CLLocationCoordinate2D? {
        guard let lat, let lng else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

struct ReservationEndpoint: Decodable, Hashable {
    let role: String
    let name: String
    let lat: Double
    let lng: Double

    var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: lat, longitude: lng) }
}

struct TripFile: Decodable, Identifiable {
    let id: Int
    let originalName: String
    let url: String
    let reservationId: Int?
    var linkedReservationIds: [Int]? = nil

    func belongs(to reservation: Reservation) -> Bool {
        reservationId == reservation.id || linkedReservationIds?.contains(reservation.id) == true
    }
}

struct Reservation: Decodable, Identifiable {
    let id: Int
    let tripId: Int
    let title: String
    let type: String
    let reservationTime: String?
    let dayId: Int?
    let location: String?
    let confirmationNumber: String?
    var status: String? = nil
    var reservationEndTime: String? = nil
    var assignmentId: Int? = nil
    var placeId: Int? = nil
    var accommodationPlaceId: Int? = nil
    var endpoints: [ReservationEndpoint]? = nil

    var time: String? { Self.clockTime(reservationTime) }
    var endTime: String? { Self.clockTime(reservationEndTime) }

    var isTransport: Bool { webTab == "transports" }

    var arrival: ReservationEndpoint? { endpoints?.first { $0.role == "to" } }

    var departure: ReservationEndpoint? { endpoints?.first { $0.role == "from" } }

    var startDate: Date? { reservationTime.flatMap { TripReminderEvents.wallClock.date(from: String($0.prefix(16))) } }

    var endDate: Date? { reservationEndTime.flatMap { TripReminderEvents.wallClock.date(from: String($0.prefix(16))) } }

    var webURL: URL? {
        guard let account = Account.load() else { return nil }
        return URL(string: "\(account.serverURL.absoluteString)/trips/\(tripId)?tab=\(webTab)")
    }

    private static func clockTime(_ value: String?) -> String? {
        guard let value, let index = value.firstIndex(of: "T") else { return nil }
        return String(value[value.index(after: index)...].prefix(5))
    }

    var date: String? {
        guard let reservationTime else { return nil }
        return String(reservationTime.prefix(10))
    }

    var webTab: String {
        ["flight", "train", "bus", "car", "cruise", "transport"].contains(type) ? "transports" : "buchungen"
    }

    var symbol: String {
        switch type {
        case "flight": "airplane"
        case "train": "tram.fill"
        case "hotel": "bed.double.fill"
        case "restaurant": "fork.knife"
        case "car": "car.fill"
        default: "ticket.fill"
        }
    }
}

struct Stay: Decodable, Identifiable {
    let id: Int
    let startDayId: Int?
    let endDayId: Int?
    let placeName: String?
    let placeAddress: String?
    let placeLat: Double?
    let placeLng: Double?
    var checkIn: String? = nil
    var checkOut: String? = nil

    var coordinate: CLLocationCoordinate2D? {
        guard let placeLat, let placeLng else { return nil }
        return CLLocationCoordinate2D(latitude: placeLat, longitude: placeLng)
    }
}

struct DayWeather: Decodable {
    let temp: Double
    let main: String

    var symbol: String {
        switch main.lowercased() {
        case "clear": "sun.max.fill"
        case "clouds": "cloud.fill"
        case "rain", "drizzle": "cloud.rain.fill"
        case "thunderstorm": "cloud.bolt.rain.fill"
        case "snow": "snowflake"
        default: "cloud.sun.fill"
        }
    }
}
