import ActivityKit
import Foundation

nonisolated struct TripActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable, Sendable {
        let nextName: String?
        let nextLeg: String?
        var nextCategory: StopCategory? = nil
        let position: Int
        let total: Int
        let doneCount: Int
        let spentToday: String
        let directionsURL: URL?
    }

    let tripTitle: String
    let dayLabel: String
    let dayTitle: String
}
