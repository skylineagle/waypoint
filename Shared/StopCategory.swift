import SwiftUI

nonisolated struct StopCategory: Codable, Hashable, Sendable {
    let name: String
    let color: String
    let icon: String

    var tint: Color {
        let value = UInt32(color.drop { $0 == "#" }, radix: 16) ?? 0x6366F1
        return Color(red: Double(value >> 16 & 0xFF) / 255, green: Double(value >> 8 & 0xFF) / 255, blue: Double(value & 0xFF) / 255)
    }

    var symbol: String {
        switch name.lowercased() {
        case "hotel": "bed.double.fill"
        case "restaurant": "fork.knife"
        case "attraction": "building.columns.fill"
        case "shopping": "bag.fill"
        case "transport": "bus.fill"
        case "activity": "figure.hiking"
        case "bar/cafe": "cup.and.saucer.fill"
        case "beach": "beach.umbrella.fill"
        case "nature": "leaf.fill"
        default: "mappin"
        }
    }
}
