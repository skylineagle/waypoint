import Foundation

enum TrekURL {
    static func resolve(_ path: String, on server: URL) -> URL? {
        guard let url = URL(string: path, relativeTo: server.appending(path: ""))?.absoluteURL,
              ["https", "http"].contains(url.scheme?.lowercased() ?? "")
        else { return nil }
        return url
    }
}
