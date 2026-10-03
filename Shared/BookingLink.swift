import Foundation

nonisolated enum BookingLink {
    static func url(_ reservationID: Int) -> URL {
        URL(string: "trekcompanion://booking?id=\(reservationID)")!
    }

    static func reservationID(in url: URL) -> Int? {
        guard url.host() == "booking" else { return nil }
        return URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first { $0.name == "id" }?.value.flatMap(Int.init)
    }
}
