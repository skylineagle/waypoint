import Foundation

nonisolated struct TripJourney: Codable, Hashable, Sendable {
    let title: String
    let symbol: String
    let from: String?
    let to: String?
    let departs: Date
    let arrives: Date?
    let confirmation: String?
    var leaveBy: Date? = nil
    var ticketURL: URL? = nil
    var directionsURL: URL? = nil

    func isOnBoard(at date: Date) -> Bool {
        date >= departs
    }
}
