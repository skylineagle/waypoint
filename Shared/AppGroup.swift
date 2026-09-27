import Foundation

nonisolated enum AppGroup {
    static let identifier = "group.dev.horizon.trekcompanion"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }
}
