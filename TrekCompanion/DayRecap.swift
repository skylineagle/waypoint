import Foundation

enum DayRecap {
    private static let doneKey = "recapped-day-ids"

    static func link(dayID: Int) -> URL {
        URL(string: "trekcompanion://recap?day=\(dayID)")!
    }

    static func dayID(in url: URL) -> Int? {
        guard url.scheme == "trekcompanion", url.host() == "recap" else { return nil }
        return URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first { $0.name == "day" }?.value.flatMap(Int.init)
    }

    static func isDone(_ dayID: Int) -> Bool {
        doneIDs.contains(dayID)
    }

    static func markDone(_ dayID: Int) {
        AppGroup.defaults.set(Array(doneIDs.union([dayID])), forKey: doneKey)
    }

    private static var doneIDs: Set<Int> {
        Set(AppGroup.defaults.array(forKey: doneKey) as? [Int] ?? [])
    }
}
