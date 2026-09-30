import CryptoKit
import Foundation

nonisolated enum WidgetPhotoStore {
    private static var directory: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroup.identifier)?
            .appending(path: "WidgetPhotos", directoryHint: .isDirectory)
    }

    static func name(for source: String) -> String {
        SHA256.hash(data: Data(source.utf8)).map { String(format: "%02x", $0) }.joined() + ".jpg"
    }

    static func load(_ name: String?) -> Data? {
        guard let name, let directory else { return nil }
        return try? Data(contentsOf: directory.appending(path: name))
    }

    static func save(_ data: Data, named name: String) throws {
        guard let directory else { return }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: directory.appending(path: name), options: .atomic)
    }

    static func clear() {
        guard let directory else { return }
        try? FileManager.default.removeItem(at: directory)
    }

    static func keep(_ names: [String]) {
        guard let directory, let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return }
        let kept = Set(names)
        for file in files where !kept.contains(file.lastPathComponent) {
            try? FileManager.default.removeItem(at: file)
        }
    }
}
