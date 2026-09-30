import SwiftUI

struct TripSegment: Decodable, Identifiable {
    let id: Int
    let name: String
    let color: String
    let effStart: Int?
    let effEnd: Int?

    func covers(dayNumber: Int) -> Bool {
        guard let effStart, let effEnd else { return false }
        return (effStart...effEnd).contains(dayNumber)
    }

    var tint: Color? {
        UInt32(color.drop { $0 == "#" }, radix: 16).map { Color(hex: $0) }
    }
}

struct TripSegmentOverview: Decodable {
    let segments: [TripSegment]
}
