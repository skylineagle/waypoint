import Foundation

@MainActor
final class JourneyUploader: NSObject, URLSessionDataDelegate {
    static let appIdentifier = "dev.horizon.trekcompanion.journey.app"
    static let shareIdentifier = "dev.horizon.trekcompanion.journey.share"
    private static var instances: [String: JourneyUploader] = [:]

    static func instance(_ identifier: String) -> JourneyUploader {
        if let existing = instances[identifier] { return existing }
        let uploader = JourneyUploader(identifier: identifier)
        instances[identifier] = uploader
        return uploader
    }

    private let identifier: String
    var backgroundCompletion: (() -> Void)?
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.sharedContainerIdentifier = JourneyStore.group
        configuration.waitsForConnectivity = true
        configuration.isDiscretionary = false
        configuration.httpCookieStorage = nil
        configuration.timeoutIntervalForResource = 7 * 24 * 3600
        return URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
    }()

    private init(identifier: String) {
        self.identifier = identifier
        super.init()
    }

    func reconnect() { _ = session }

    static func pause(scope: String) async {
        guard let store = try? JourneyStore.shared(), let uploads = try? store.list() else { return }
        for upload in uploads where upload.destination.scope == scope {
            for identifier in Set(upload.photos.compactMap(\.sessionIdentifier)) {
                let tasks = await instance(identifier).session.allTasks
                for task in tasks where task.taskDescription?.hasPrefix(upload.id.uuidString + "/") == true { task.cancel() }
            }
        }
    }

    func start() throws {
        reconnect()
        guard let account = JourneySession.load() else { return }
        let store = try JourneyStore.shared()
        for upload in try store.list() where upload.destination.scope == account.scope {
            for photo in upload.photos where photo.state == .queued {
                var request = try JourneyStore.request("api/journeys/\(upload.destination.id)/gallery/photos", session: account)
                request.httpMethod = "POST"
                request.setValue("multipart/form-data; boundary=Waypoint-\(photo.id.uuidString)", forHTTPHeaderField: "Content-Type")
                let body = try store.body(photo, upload: upload.id)
                var task: URLSessionUploadTask?
                try store.update(upload.id) { latest in
                    guard let index = latest.photos.firstIndex(where: { $0.id == photo.id && $0.state == .queued }) else { return }
                    try? FileManager.default.removeItem(at: store.response(photo.id, upload: upload.id))
                    let created = session.uploadTask(with: request, fromFile: body)
                    created.taskDescription = "\(upload.id.uuidString)/\(photo.id.uuidString)"
                    latest.photos[index].state = .uploading
                    latest.photos[index].message = nil
                    latest.photos[index].sessionIdentifier = identifier
                    latest.photos[index].taskIdentifier = created.taskIdentifier
                    task = created
                }
                task?.resume()
            }
        }
    }

    func retry(_ uploadID: UUID, allowUncertain: Bool = false) async throws {
        guard let account = JourneySession.load() else { throw JourneyError.signIn }
        let store = try JourneyStore.shared()
        guard let upload = try store.list().first(where: { $0.id == uploadID }), upload.destination.scope == account.scope else {
            throw JourneyError.message("Sign in to the account that originally shared these photos.")
        }
        for photo in upload.photos where photo.state != .uploading {
            if photo.state == .uncertain, !allowUncertain {
                if try await JourneyAPI(session: account).contains(photo, in: upload.destination) {
                    try store.update(upload.id) { $0.photos.removeAll { $0.id == photo.id } }
                } else {
                    try store.update(upload.id) { latest in
                        guard let index = latest.photos.firstIndex(where: { $0.id == photo.id }) else { return }
                        latest.photos[index].message = "Couldn't confirm this photo in TREK. Check the gallery before sending it again."
                    }
                }
            } else {
                try store.update(upload.id) { latest in
                    guard let index = latest.photos.firstIndex(where: { $0.id == photo.id && $0.state != .uploading }) else { return }
                    latest.photos[index].state = .queued
                    latest.photos[index].message = nil
                }
            }
        }
        try start()
    }

    static func cancel(_ upload: JourneyUpload) async throws {
        let store = try JourneyStore.shared()
        for identifier in Set(upload.photos.compactMap(\.sessionIdentifier)) {
            let uploader = instance(identifier)
            let tasks = await uploader.session.allTasks
            for task in tasks where task.taskDescription?.hasPrefix(upload.id.uuidString + "/") == true { task.cancel() }
        }
        try store.remove(upload.id)
    }

    nonisolated func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let ids = Self.ids(dataTask.taskDescription) else { return }
        Task { @MainActor in
            guard let store = try? JourneyStore.shared() else { return }
            let path = store.response(ids.photo, upload: ids.upload)
            do {
                if !FileManager.default.fileExists(atPath: path.path) { try Data().write(to: path) }
                let handle = try FileHandle(forWritingTo: path)
                defer { try? handle.close() }
                try handle.seekToEnd()
                try handle.write(contentsOf: data)
            } catch { }
        }
    }

    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let ids = Self.ids(task.taskDescription) else { return }
        let status = (task.response as? HTTPURLResponse)?.statusCode ?? 0
        let response = task.response as? HTTPURLResponse
        let taskID = task.taskIdentifier
        let sessionID = session.configuration.identifier
        Task { @MainActor in
            do {
                let store = try JourneyStore.shared()
                struct Response: Decodable {
                    struct Photo: Decodable { let id: Int }
                    let photos: [Photo]
                }
                let bytes = (try? Data(contentsOf: store.response(ids.photo, upload: ids.upload))) ?? Data()
                let galleryPhotos = (try? JSONDecoder().decode(Response.self, from: bytes))?.photos ?? []
                let confirmed = galleryPhotos.count == 1
                var link: (entryID: Int, photoID: Int)?
                let state = JourneyStore.result(status: status, confirmed: confirmed, error: error != nil)
                try store.update(ids.upload) { upload in
                    guard let index = upload.photos.firstIndex(where: {
                        $0.id == ids.photo && $0.taskIdentifier == taskID && $0.sessionIdentifier == sessionID
                    }) else { return }
                    if let response { JourneySession.renew(from: response, for: upload.destination.scope) }
                    if let state {
                        upload.photos[index].state = state
                        upload.photos[index].message = Self.message(status: status, state: state)
                    } else {
                        if let entryID = upload.photos[index].entryID, let photo = galleryPhotos.first { link = (entryID, photo.id) }
                        upload.photos.remove(at: index)
                    }
                }
                if let link, let account = JourneySession.load() {
                    try? await JourneyAPI(session: account).link(galleryPhoto: link.photoID, toEntry: link.entryID)
                }
            } catch {
                NSLog("Journey upload result could not be saved: %@", error.localizedDescription)
            }
        }
    }

    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping @Sendable (URLRequest?) -> Void) {
        completionHandler(nil)
    }

    nonisolated func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        Task { @MainActor in
            let completion = backgroundCompletion
            backgroundCompletion = nil
            completion?()
        }
    }

    nonisolated private static func ids(_ description: String?) -> (upload: UUID, photo: UUID)? {
        guard let parts = description?.split(separator: "/"), parts.count == 2,
              let upload = UUID(uuidString: String(parts[0])), let photo = UUID(uuidString: String(parts[1])) else { return nil }
        return (upload, photo)
    }

    nonisolated private static func message(status: Int, state: JourneyUpload.State) -> String {
        switch state {
        case .signIn: "Sign in to TREK to finish sending."
        case .uncertain: "The upload wasn't confirmed. Check the gallery before retrying."
        case .failed:
            status == 403 ? "You no longer have permission to add photos to this Journey."
                : status == 404 ? "Journey is unavailable. Check the addon and destination in TREK."
                : status == 413 ? "This photo exceeds the server's upload limit."
                : "TREK declined this photo (status \(status))."
        case .queued, .uploading: "Waiting for a connection to TREK."
        }
    }
}
