import Foundation

nonisolated struct StopHere: Codable, Hashable, Sendable {
    let stopID: Int
    let since: Date

    private static let key = "stop-here"

    static func load() -> StopHere? {
        AppGroup.defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(StopHere.self, from: $0) }
    }

    @discardableResult
    static func save(_ here: StopHere?) -> Bool {
        guard here != load() else { return false }
        AppGroup.defaults.set(here.flatMap { try? JSONEncoder().encode($0) }, forKey: key)
        return true
    }
}
