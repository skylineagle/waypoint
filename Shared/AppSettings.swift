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
    static let todoReminderDaysKey = "todo-reminder-days"
    static let todoReminderMinuteKey = "todo-reminder-minute"
    static let defaultTodoReminderMinute = 9 * 60
    static let flightLeadMinutesKey = "flight-lead-minutes"
    static let bookingLeadMinutesKey = "booking-lead-minutes"
    static let flightCheckInKey = "flight-check-in-reminder"
    static let morningMinuteKey = "morning-minute"
    static let defaultMorningMinute = 8 * 60
    static let recapMinuteKey = "recap-minute"
    static let defaultRecapMinute = 21 * 60

    static var directionsApp: DirectionsApp {
        DirectionsApp(rawValue: AppGroup.defaults.string(forKey: directionsAppKey) ?? "") ?? .appleMaps
    }

    static var isLiveActivityEnabled: Bool {
        AppGroup.defaults.object(forKey: liveActivityKey) as? Bool ?? true
    }

    static var isWidgetPhotosEnabled: Bool {
        AppGroup.defaults.object(forKey: widgetPhotosKey) as? Bool ?? true
    }

    static var flightLeadMinutes: Int {
        AppGroup.defaults.object(forKey: flightLeadMinutesKey) as? Int ?? 180
    }

    static var bookingLeadMinutes: Int {
        AppGroup.defaults.object(forKey: bookingLeadMinutesKey) as? Int ?? 60
    }

    static var isFlightCheckInEnabled: Bool {
        AppGroup.defaults.object(forKey: flightCheckInKey) as? Bool ?? true
    }

    static var recapMinute: Int {
        AppGroup.defaults.object(forKey: recapMinuteKey) as? Int ?? defaultRecapMinute
    }

    static var morningMinute: Int {
        AppGroup.defaults.object(forKey: morningMinuteKey) as? Int ?? defaultMorningMinute
    }

    static var todoReminderDays: Int {
        AppGroup.defaults.object(forKey: todoReminderDaysKey) as? Int ?? 1
    }

    static var todoReminderMinute: Int {
        AppGroup.defaults.object(forKey: todoReminderMinuteKey) as? Int ?? defaultTodoReminderMinute
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
