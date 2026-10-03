import SwiftUI

enum ActivityUrgency {
    case calm, soon, late

    init(leaveBy: Date, now: Date = .now) {
        let remaining = leaveBy.timeIntervalSince(now)
        self = remaining < 0 ? .late : remaining <= 15 * 60 ? .soon : .calm
    }

    var tint: Color {
        switch self {
        case .calm: .white.opacity(0.85)
        case .soon: Color(red: 0xFC / 255, green: 0xD3 / 255, blue: 0x4D / 255)
        case .late: Color(red: 0xF8 / 255, green: 0x71 / 255, blue: 0x71 / 255)
        }
    }
}
