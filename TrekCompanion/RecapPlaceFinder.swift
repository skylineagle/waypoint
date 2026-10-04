import MapKit

enum RecapPlaceFinder {
    static let nearbyMeters = 75.0
    static let nearbyLimit = 5
    static let searchMeters = 20_000.0

    static func nearby(_ coordinate: CLLocationCoordinate2D) async -> [RecapCandidate] {
        let request = MKLocalPointsOfInterestRequest(center: coordinate, radius: nearbyMeters)
        let items = (try? await MKLocalSearch(request: request).start().mapItems) ?? []
        guard !items.isEmpty else { return await address(of: coordinate) }
        return Array(candidates(from: items, near: coordinate).prefix(nearbyLimit))
    }

    static func search(_ query: String, near coordinate: CLLocationCoordinate2D) async -> [RecapCandidate] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: searchMeters, longitudinalMeters: searchMeters)
        request.resultTypes = [.pointOfInterest, .address]
        let items = (try? await MKLocalSearch(request: request).start().mapItems) ?? []
        return candidates(from: items, near: coordinate)
    }

    private static func address(of coordinate: CLLocationCoordinate2D) async -> [RecapCandidate] {
        guard let request = MKReverseGeocodingRequest(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) else { return [] }
        let items = (try? await request.mapItems) ?? []
        return Array(candidates(from: items, near: coordinate).prefix(1))
    }

    private static func candidates(from items: [MKMapItem], near coordinate: CLLocationCoordinate2D) -> [RecapCandidate] {
        let here = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return items
            .compactMap { item -> (candidate: RecapCandidate, meters: Double)? in
                guard let name = item.name else { return nil }
                let meters = here.distance(from: item.location)
                let distance = Measurement(value: meters, unit: UnitLength.meters).formatted(.measurement(width: .abbreviated, usage: .road))
                let detail = [item.pointOfInterestCategory.map(label), distance].compactMap(\.self).joined(separator: " · ")
                let candidate = RecapCandidate(name: name, detail: detail, latitude: item.location.coordinate.latitude, longitude: item.location.coordinate.longitude)
                return (candidate, meters)
            }
            .sorted { $0.meters < $1.meters }
            .map(\.candidate)
    }

    private static func label(of category: MKPointOfInterestCategory) -> String {
        let name = category.rawValue.replacingOccurrences(of: "MKPOICategory", with: "")
        let words = name.replacing(/([a-z])([A-Z])/) { "\($0.1) \($0.2)" }
        return words.prefix(1) + words.dropFirst().lowercased()
    }
}
