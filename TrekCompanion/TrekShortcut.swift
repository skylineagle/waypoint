import Foundation

enum TrekShortcut {
    static let name = "Waypoint - TREK Expenses"
    static let automations = URL(string: "shortcuts://automations")!
    static let link = URL(string: "https://www.icloud.com/shortcuts/1510863a1f61429083fe99bb21d3842f")!
}

enum ShortcutCheck {
    case idle, added, found
}
