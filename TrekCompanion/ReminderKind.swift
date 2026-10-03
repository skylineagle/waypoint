import SwiftUI

enum ReminderKind: String, CaseIterable, Identifiable {
    case todos, bookings, stays, brief, countdown, recap

    var id: Self { self }

    var title: String {
        switch self {
        case .todos: "To-dos"
        case .bookings: "Bookings"
        case .stays: "Stays"
        case .brief: "Morning brief"
        case .countdown: "Trip countdown"
        case .recap: "Day recap"
        }
    }

    var symbol: String {
        switch self {
        case .todos: "checklist"
        case .bookings: "airplane"
        case .stays: "bed.double.fill"
        case .brief: "sun.max.fill"
        case .countdown: "hourglass"
        case .recap: "photo.on.rectangle.angled"
        }
    }

    var tint: Color {
        switch self {
        case .todos: Color(hex: 0x0A84FF)
        case .bookings: Color(hex: 0x5E5CE6)
        case .stays: Color(hex: 0xFF9F0A)
        case .brief: Color(hex: 0x30D158)
        case .countdown: Color(hex: 0xFF375F)
        case .recap: Color(hex: 0xBF5AF2)
        }
    }

    var link: URL {
        URL(string: self == .todos ? "trekcompanion://todos" : "trekcompanion://today")!
    }

    var usesMorningTime: Bool { self == .brief || self == .countdown }

    var enabledKey: String { "notify-\(rawValue)" }

    var isEnabled: Bool {
        AppGroup.defaults.object(forKey: enabledKey) as? Bool ?? true
    }
}
