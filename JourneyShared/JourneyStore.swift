import CryptoKit
import Darwin
import Foundation

nonisolated struct JourneyStore {
    static let group = AppGroup.identifier
    let directory: URL

    static func shared() throws -> Self {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) else {
            throw JourneyError.message("Photo sharing isn't configured. Open Waypoint first.")
        }
        return Self(directory: container.appending(path: "JourneyUploads", directoryHint: .isDirectory))
    }

    func list() throws -> [JourneyUpload] {
        try locked {
            try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
                .filter { UUID(uuidString: $0.lastPathComponent) != nil }
                .map { try JSONDecoder().decode(JourneyUpload.self, from: Data(contentsOf: $0.appending(path: "upload.json"))) }
                .sorted { $0.createdAt < $1.createdAt }
        }
    }

    func enqueue(_ files: [URL], entryIDs: [URL: Int] = [:], destination: JourneyDestination) throws -> JourneyUpload {
        guard !files.isEmpty else { throw JourneyError.message("Choose at least one photo.") }
        return try locked {
            let id = UUID()
            let staging = directory.appending(path: "\(id.uuidString).staging", directoryHint: .isDirectory)
            try FileManager.default.createDirectory(at: staging, withIntermediateDirectories: true)
            do {
                var photos: [JourneyUpload.Photo] = []
                for source in files {
                    let bytes = try Data(contentsOf: source, options: .mappedIfSafe)
                    guard !bytes.isEmpty, bytes.count <= 20 * 1024 * 1024 else {
                        throw JourneyError.message("Each photo must be smaller than 20 MB. Your selection has not been sent.")
                    }
                    let photoID = UUID()
                    let name = "\(photoID.uuidString).\(source.pathExtension.lowercased())"
                    try bytes.write(to: staging.appending(path: name), options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
                    photos.append(.init(id: photoID, fileName: name, checksum: Self.checksum(bytes), entryID: entryIDs[source]))
                }
                let upload = JourneyUpload(id: id, destination: destination, createdAt: .now, photos: photos)
                try JSONEncoder().encode(upload).write(to: staging.appending(path: "upload.json"), options: .atomic)
                try FileManager.default.moveItem(at: staging, to: folder(id))
                return upload
            } catch {
                try? FileManager.default.removeItem(at: staging)
                throw error
            }
        }
    }

    func update(_ id: UUID, _ change: (inout JourneyUpload) throws -> Void) throws {
        try locked {
            let path = folder(id).appending(path: "upload.json")
            guard FileManager.default.fileExists(atPath: path.path) else { return }
            var upload = try JSONDecoder().decode(JourneyUpload.self, from: Data(contentsOf: path))
            try change(&upload)
            if upload.photos.isEmpty {
                try FileManager.default.removeItem(at: folder(id))
            } else {
                try JSONEncoder().encode(upload).write(to: path, options: .atomic)
            }
        }
    }

    func remove(_ id: UUID) throws {
        try locked {
            if FileManager.default.fileExists(atPath: folder(id).path) { try FileManager.default.removeItem(at: folder(id)) }
        }
    }

    func file(_ photo: JourneyUpload.Photo, upload: UUID) -> URL { folder(upload).appending(path: photo.fileName) }
    func response(_ photo: UUID, upload: UUID) -> URL { folder(upload).appending(path: "\(photo.uuidString).response") }

    func body(_ photo: JourneyUpload.Photo, upload: UUID) throws -> URL {
        let boundary = "Waypoint-\(photo.id.uuidString)"
        let type = photo.fileName.hasSuffix(".png") ? "image/png" : "image/jpeg"
        var bytes = Data("--\(boundary)\r\nContent-Disposition: form-data; name=\"photos\"; filename=\"\(photo.fileName)\"\r\nContent-Type: \(type)\r\n\r\n".utf8)
        bytes.append(try Data(contentsOf: file(photo, upload: upload), options: .mappedIfSafe))
        bytes.append(Data("\r\n--\(boundary)--\r\n".utf8))
        let path = folder(upload).appending(path: "\(photo.id.uuidString).multipart")
        try bytes.write(to: path, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        return path
    }

    static func request(_ path: String, session: JourneySession) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: session.serverURL.appending(path: ""))?.absoluteURL,
              ["https", "http"].contains(url.scheme?.lowercased() ?? ""),
              url.host == session.serverURL.host, url.port == session.serverURL.port else {
            throw JourneyError.message("The TREK server address is invalid.")
        }
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = false
        request.setValue("trek_session=\(session.token)", forHTTPHeaderField: "Cookie")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    static func checksum(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    static func result(status: Int, confirmed: Bool, error: Bool) -> JourneyUpload.State? {
        if (200..<300).contains(status), confirmed, !error { return nil }
        if status == 401 { return .signIn }
        if (400..<500).contains(status), status != 408 { return .failed }
        return .uncertain
    }

    private func folder(_ id: UUID) -> URL { directory.appending(path: id.uuidString, directoryHint: .isDirectory) }

    private func locked<Value>(_ operation: () throws -> Value) throws -> Value {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let descriptor = open(directory.appending(path: ".lock").path, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
        guard descriptor >= 0 else { throw JourneyError.message("Couldn't save your photos on this phone.") }
        defer { close(descriptor) }
        guard flock(descriptor, LOCK_EX) == 0 else { throw JourneyError.message("Couldn't access pending photos. Try again.") }
        defer { flock(descriptor, LOCK_UN) }
        return try operation()
    }
}
