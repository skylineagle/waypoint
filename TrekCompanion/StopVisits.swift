import CoreLocation

nonisolated struct StopVisit: Codable, Equatable {
    let stopID: Int
    let since: Date
    var lastSeen: Date
}

nonisolated enum StopVisits {
    struct Place {
        let id: Int
        let latitude: Double
        let longitude: Double
        var isDone = false
    }

    static let radius: CLLocationDistance = 100

    /// The undone stop you're at. Standing at a done stop counts for no other stop, even one within range.
    static func nearest(to location: CLLocation, in places: [Place], within meters: CLLocationDistance = radius) -> Int? {
        let closest = places
            .map { (place: $0, meters: location.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude))) }
            .filter { $0.meters <= meters }
            .min { $0.meters < $1.meters }?.place
        return closest?.isDone == false ? closest?.id : nil
    }

    static func step(_ visit: StopVisit?, places: [Place], at location: CLLocation, dwell: TimeInterval) -> (visit: StopVisit?, done: Int?) {
        let here = nearest(to: location, in: places)
        let now = location.timestamp
        let arrival = here.map { StopVisit(stopID: $0, since: now, lastSeen: now) }
        guard var visit, places.contains(where: { $0.id == visit.stopID && !$0.isDone }) else {
            return (arrival, nil)
        }
        if here == visit.stopID {
            visit.lastSeen = now
            return visit.lastSeen.timeIntervalSince(visit.since) >= dwell ? (nil, visit.stopID) : (visit, nil)
        }
        return (arrival, visit.lastSeen.timeIntervalSince(visit.since) >= dwell ? visit.stopID : nil)
    }
}
