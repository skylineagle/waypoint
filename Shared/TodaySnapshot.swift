import Foundation

nonisolated struct TodaySnapshot: Codable, Hashable, Sendable {
    struct Stop: Codable, Hashable, Sendable {
        let id: Int
        let name: String
        let latitude: Double?
        let longitude: Double?
        let leg: String?
        var photoName: String? = nil
        var category: StopCategory? = nil
        var bookedAt: Date? = nil
        var leaveBy: Date? = nil
        var journey: TripJourney? = nil
        var ticketURL: URL? = nil
    }

    let tripID: Int
    let tripTitle: String
    let dayLabel: String
    let dayTitle: String
    let date: String
    let stops: [Stop]
    let spentToday: String
    let dailyAverage: String?
    let countdown: String?
    var coverPhotoName: String? = nil

    var photoName: String? {
        countdown == nil ? next?.photoName : coverPhotoName
    }

    private static let key = "today-snapshot"

    static func doneKey(tripID: Int) -> String {
        "done-stops-\(tripID)"
    }

    static func load() -> TodaySnapshot? {
        guard let data = AppGroup.defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(TodaySnapshot.self, from: data)
    }

    static func clear() {
        AppGroup.defaults.removeObject(forKey: key)
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        AppGroup.defaults.set(data, forKey: Self.key)
    }

    var doneIDs: Set<Int> {
        Set(AppGroup.defaults.array(forKey: Self.doneKey(tripID: tripID)) as? [Int] ?? [])
    }

    var next: Stop? {
        let done = doneIDs
        return stops.first { !done.contains($0.id) }
    }

    var here: (stop: Stop, since: Date)? {
        guard let here = StopHere.load(), !doneIDs.contains(here.stopID),
              let stop = stops.first(where: { $0.id == here.stopID })
        else { return nil }
        return (stop, here.since)
    }

    var current: Stop? {
        here?.stop ?? next
    }

    var doneCount: Int {
        let done = doneIDs
        return stops.filter { done.contains($0.id) }.count
    }

    var position: Int {
        guard let next, let index = stops.firstIndex(of: next) else { return stops.count }
        return index + 1
    }

    func markDone(_ stopID: Int) {
        var done = doneIDs
        done.insert(stopID)
        AppGroup.defaults.set(Array(done), forKey: Self.doneKey(tripID: tripID))
    }

    var directionsURL: URL? {
        guard let next, let latitude = next.latitude, let longitude = next.longitude else { return nil }
        return AppSettings.directionsLink(latitude: latitude, longitude: longitude)
    }

    var activityState: TripActivityAttributes.ContentState {
        var state = TripActivityAttributes.ContentState(
            nextName: next?.name,
            nextLeg: next?.leg,
            nextCategory: next?.category,
            position: position,
            total: stops.count,
            doneCount: doneCount,
            spentToday: spentToday,
            directionsURL: directionsURL,
            nextBookedAt: next?.bookedAt,
            leaveBy: next?.leaveBy,
            journey: next?.journey,
            nextTicketURL: next?.ticketURL
        )
        if let here {
            let done = doneIDs
            let then = stops.first { !done.contains($0.id) && $0.id != here.stop.id }
            state.here = TripActivityAttributes.Here(
                name: here.stop.name,
                category: here.stop.category,
                since: here.since,
                thenName: then?.journey?.title ?? then?.name,
                thenLeaveBy: then?.journey?.leaveBy ?? then?.leaveBy,
                ticketURL: here.stop.ticketURL
            )
        }
        return state
    }

    static let preview = TodaySnapshot(
        tripID: 0,
        tripTitle: "Japan",
        dayLabel: "Day 3 of 20",
        dayTitle: "Asakusa & Ueno",
        date: "2026-10-07",
        stops: [
            Stop(id: 1, name: "Sensō-ji", latitude: nil, longitude: nil, leg: nil),
            Stop(id: 2, name: "Nakamise Street", latitude: nil, longitude: nil, leg: "4 min walk"),
        ],
        spentToday: "₪212",
        dailyAverage: "₪416",
        countdown: nil
    )
}
