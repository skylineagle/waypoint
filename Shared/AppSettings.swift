import Foundation

nonisolated enum DirectionsApp: String, CaseIterable, Identifiable, Sendable {
    case appleMaps, googleMaps, waze

    var id: Self { self }

    var name: String {
        switch self {
        case .appleMaps: "Apple Maps"
        case .googleMaps: "Google Maps"
        case .waze: "Waze"
        }
    }

    func url(latitude: Double, longitude: Double) -> URL {
        let destination = "\(latitude),\(longitude)"
        return switch self {
        case .appleMaps: URL(string: "https://maps.apple.com/?daddr=\(destination)")!
        case .googleMaps: URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(destination)")!
        case .waze: URL(string: "https://waze.com/ul?ll=\(destination)&navigate=yes")!
        }
    }
}

nonisolated enum AppSettings {
    static let directionsAppKey = "directions-app"
    static let liveActivityKey = "live-activity-enabled"
    static let widgetPhotosKey = "widget-photos-enabled"

    static var directionsApp: DirectionsApp {
        DirectionsApp(rawValue: AppGroup.defaults.string(forKey: directionsAppKey) ?? "") ?? .appleMaps
    }

    static var isLiveActivityEnabled: Bool {
        AppGroup.defaults.object(forKey: liveActivityKey) as? Bool ?? true
    }

    static var isWidgetPhotosEnabled: Bool {
        AppGroup.defaults.object(forKey: widgetPhotosKey) as? Bool ?? true
    }

    static func directionsLink(latitude: Double, longitude: Double) -> URL {
        URL(string: "trekcompanion://directions?lat=\(latitude)&lng=\(longitude)")!
    }

    static func resolveDirectionsLink(_ url: URL) -> URL? {
        guard url.host() == "directions",
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let latitude = items.first(where: { $0.name == "lat" })?.value.flatMap(Double.init),
              let longitude = items.first(where: { $0.name == "lng" })?.value.flatMap(Double.init)
        else { return nil }
        return directionsApp.url(latitude: latitude, longitude: longitude)
    }
}
