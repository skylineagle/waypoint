import CoreLocation
import Foundation

nonisolated struct JourneyStop: Decodable, Identifiable, Equatable {
    static let matchRadiusMeters = 500.0

    let id: Int
    let entryDate: String
    let entryTime: String?
    let title: String?
    let locationName: String?
    let locationLat: Double?
    let locationLng: Double?

    var name: String {
        [title, locationName].compactMap { $0 }.first { !$0.isEmpty } ?? "Stop"
    }

    static func nearest(to taken: JourneyPhoto.Taken, in stops: [JourneyStop]) -> JourneyStop? {
        guard let latitude = taken.latitude, let longitude = taken.longitude else { return nil }
        let photo = CLLocation(latitude: latitude, longitude: longitude)
        return stops
            .filter { $0.entryDate == taken.day }
            .compactMap { stop -> (JourneyStop, Double)? in
                guard let lat = stop.locationLat, let lng = stop.locationLng else { return nil }
                return (stop, photo.distance(from: CLLocation(latitude: lat, longitude: lng)))
            }
            .filter { $0.1 <= matchRadiusMeters }
            .min { $0.1 < $1.1 }?.0
    }
}
