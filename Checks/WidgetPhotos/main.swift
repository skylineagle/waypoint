import Foundation

enum AppGroup {
    static let identifier = "waypoint-widget-check-\(UUID().uuidString)"
    static let defaults = UserDefaults(suiteName: identifier)!
}

struct TripActivityAttributes {
    struct Here {
        let name: String
        var category: StopCategory? = nil
        let since: Date
        let thenName: String?
        let thenLeaveBy: Date?
        let ticketURL: URL?
    }

    struct ContentState {
        let nextName: String?
        let nextLeg: String?
        var nextCategory: StopCategory? = nil
        let position: Int
        let total: Int
        let doneCount: Int
        let spentToday: String
        let directionsURL: URL?
        var nextBookedAt: Date? = nil
        var leaveBy: Date? = nil
        var here: Here? = nil
        var journey: TripJourney? = nil
        var nextTicketURL: URL? = nil
    }
}

defer { AppGroup.defaults.removePersistentDomain(forName: AppGroup.identifier) }

let legacy = Data(#"{"tripID":123,"tripTitle":"Portugal","dayLabel":"Day 1","dayTitle":"Lisbon","date":"2026-09-29","stops":[{"id":1,"name":"Castle"},{"id":2,"name":"Square"}],"spentToday":"€42"}"#.utf8)
let original = try JSONDecoder().decode(TodaySnapshot.self, from: legacy)
precondition(original.photoName == nil, "Existing snapshots must remain readable without photos")

var current = original
var stops = original.stops
stops[0].photoName = "castle.jpg"
stops[1].photoName = "square.jpg"
current = TodaySnapshot(
    tripID: original.tripID, tripTitle: original.tripTitle,
    dayLabel: original.dayLabel, dayTitle: original.dayTitle, date: original.date,
    stops: stops, spentToday: original.spentToday, dailyAverage: nil, countdown: nil,
    coverPhotoName: "cover.jpg"
)
precondition(current.photoName == "castle.jpg", "Use the displayed next stop's photo")
current.markDone(1)
precondition(current.photoName == "square.jpg", "Advance the photo with the next stop")
current.markDone(2)
precondition(current.photoName == nil, "A completed day has the solid background")

let future = TodaySnapshot(
    tripID: 123, tripTitle: "Portugal", dayLabel: "Starts in", dayTitle: "Portugal",
    date: "2026-10-01", stops: [], spentToday: "€0", dailyAverage: nil,
    countdown: "2 days", coverPhotoName: "cover.jpg"
)
precondition(future.photoName == "cover.jpg", "Before departure use the trip cover")
let encoded = try JSONEncoder().encode(future)
let decoded = try JSONDecoder().decode(TodaySnapshot.self, from: encoded)
precondition(decoded.photoName == "cover.jpg")
precondition(AppSettings.isWidgetPhotosEnabled, "Photos default to enabled")
AppGroup.defaults.set(false, forKey: AppSettings.widgetPhotosKey)
precondition(!AppSettings.isWidgetPhotosEnabled, "The off setting must be shared with the widget")
precondition(WidgetPhotoStore.load(nil) == nil)
let name = WidgetPhotoStore.name(for: "https://example.com/uploads/cover.jpg")
precondition(name.count == 68 && name.hasSuffix(".jpg") && !name.contains("/"))
precondition(name != WidgetPhotoStore.name(for: "https://other.example/uploads/cover.jpg"))
let server = URL(string: "https://example.com/trek")!
precondition(TrekURL.resolve("api/trips?limit=1", on: server)?.absoluteString == "https://example.com/trek/api/trips?limit=1")
precondition(TrekURL.resolve("api/maps/place-photo/coords%3A38%2C9", on: server)?.absoluteString == "https://example.com/trek/api/maps/place-photo/coords%3A38%2C9")
precondition(TrekURL.resolve("/uploads/cover.jpg", on: server)?.absoluteString == "https://example.com/uploads/cover.jpg")
precondition(TrekURL.resolve("https://photos.example/a%2Fb.jpg", on: server)?.absoluteString == "https://photos.example/a%2Fb.jpg")
precondition(TrekURL.resolve("file:///etc/passwd", on: server) == nil)
print("Widget photo checks passed")
