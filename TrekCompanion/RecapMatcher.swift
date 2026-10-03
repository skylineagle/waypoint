import CoreLocation
import Foundation

nonisolated enum RecapMatcher {
    struct Place {
        let id: Int
        let latitude: Double?
        let longitude: Double?
        let arrival: Date?
    }

    struct Photo {
        let id: String
        let date: Date
        let latitude: Double?
        let longitude: Double?
        var isFavorite = false
    }

    static let radiusMeters = 500.0
    static let pickCount = 3

    /// A photo goes to the nearest place within range. Without a location, or with none in range, it goes to the place you had most recently arrived at.
    static func placeID(of photo: Photo, among places: [Place]) -> Int? {
        if let latitude = photo.latitude, let longitude = photo.longitude {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let nearest = places
                .compactMap { place -> (id: Int, meters: Double)? in
                    guard let lat = place.latitude, let lng = place.longitude else { return nil }
                    return (place.id, location.distance(from: CLLocation(latitude: lat, longitude: lng)))
                }
                .filter { $0.meters <= radiusMeters }
                .min { $0.meters < $1.meters }?.id
            if let nearest { return nearest }
        }
        return places
            .compactMap { place in place.arrival.map { (id: place.id, arrival: $0) } }
            .filter { $0.arrival <= photo.date }
            .max { $0.arrival < $1.arrival }?.id
    }

    /// Favourites first, then photos spread evenly across the visit so the picks aren't three shots of the same moment.
    static func picks(from photos: [Photo]) -> [String] {
        let favorites = photos.filter(\.isFavorite).prefix(pickCount).map(\.id)
        let rest = photos.filter { !$0.isFavorite }.sorted { $0.date < $1.date }
        let needed = min(pickCount - favorites.count, rest.count)
        guard needed > 0 else { return Array(favorites) }
        let spread = (0..<needed).map { rest[$0 * rest.count / needed].id }
        return favorites + spread
    }
}
