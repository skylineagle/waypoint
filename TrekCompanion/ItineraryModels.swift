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

    var coordinate: CLLocationCoordinate2D? {
        guard let lat, let lng else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
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

    var time: String? {
        guard let reservationTime, let index = reservationTime.firstIndex(of: "T") else { return nil }
        return String(reservationTime[reservationTime.index(after: index)...].prefix(5))
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
