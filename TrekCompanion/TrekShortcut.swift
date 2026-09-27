import Foundation

enum TrekShortcut {
    static let name = "Add to TREK"
    static let file = Bundle.main.url(forResource: name, withExtension: "shortcut")!

    static var checkURL: URL {
        var components = URLComponents(string: "shortcuts://x-callback-url/run-shortcut")!
        components.queryItems = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "input", value: "text"),
            URLQueryItem(name: "text", value: "check"),
            URLQueryItem(name: "x-success", value: "trekcompanion://shortcut/found"),
            URLQueryItem(name: "x-error", value: "trekcompanion://shortcut/missing"),
            URLQueryItem(name: "x-cancel", value: "trekcompanion://shortcut/missing"),
        ]
        return components.url!
    }
}

enum ShortcutCheck {
    case idle, checking, found, missing

    init?(callback url: URL) {
        guard url.scheme == "trekcompanion", url.host() == "shortcut" else { return nil }
        self = url.lastPathComponent == "found" ? .found : .missing
    }
}
