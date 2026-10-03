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
        var nextBookedAt: Date? = nil
        var leaveBy: Date? = nil
        var here: Here? = nil
        var journey: TripJourney? = nil
        var nextTicketURL: URL? = nil
    }

    struct Here: Codable, Hashable, Sendable {
        let name: String
        var category: StopCategory? = nil
        let since: Date
        let thenName: String?
        let thenLeaveBy: Date?
        let ticketURL: URL?
    }

    let tripTitle: String
    let dayLabel: String
    let dayTitle: String
}
