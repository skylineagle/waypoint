import Foundation

struct JourneyAPI {
    let session: JourneySession
    private static let transport = URLSession(configuration: .ephemeral, delegate: JourneyRedirectGuard(), delegateQueue: nil)

    func destinations() async throws -> [JourneyDestination] {
        struct List: Decodable {
            struct Item: Decodable { let id: Int }
            let journeys: [Item]
        }
        let list: List = try await request("GET", "api/journeys")
        var destinations: [JourneyDestination] = []
        for item in list.journeys {
            let detail = try await detail(item.id)
            if let destination = detail.destination(for: session) { destinations.append(destination) }
        }
        return destinations
    }

    func detail(_ id: Int) async throws -> JourneyDetail {
        try await request("GET", "api/journeys/\(id)")
    }

    func stops(in journeyID: Int) async throws -> [JourneyStop] {
        struct List: Decodable { let entries: [JourneyStop] }
        let list: List = try await request("GET", "api/journeys/\(journeyID)/entries")
        return list.entries
    }

    func link(galleryPhoto photoID: Int, toEntry entryID: Int) async throws {
        struct Input: Encodable { let journey_photo_id: Int }
        _ = try await data("POST", "api/journeys/entries/\(entryID)/link-photo", body: JSONEncoder().encode(Input(journey_photo_id: photoID)))
    }

    func stampArrival(assignment assignmentID: Int, at time: String) async throws {
        let saved = JourneyDestination.saved(for: session)?.id
        let journeys = try await destinations()
        guard let journeyID = (journeys.first { $0.id == saved } ?? journeys.first)?.id,
              let entry = try await stops(in: journeyID).first(where: { $0.sourceAssignmentId == assignmentID }),
              entry.isUntouched
        else { return }
        struct Input: Encodable { let entry_time: String }
        _ = try await data("PATCH", "api/journeys/entries/\(entry.id)", body: JSONEncoder().encode(Input(entry_time: time)))
    }

    func write(story: String, toEntry entryID: Int) async throws {
        struct Input: Encodable { let story: String }
        _ = try await data("PATCH", "api/journeys/entries/\(entryID)", body: JSONEncoder().encode(Input(story: story)))
    }

    func createEntry(in journeyID: Int, date: String, time: String?, name: String, latitude: Double, longitude: Double, story: String) async throws -> Int {
        struct Input: Encodable {
            let entry_date: String
            let entry_time: String?
            let title: String
            let location_name: String
            let location_lat: Double
            let location_lng: Double
            let story: String?
        }
        struct Created: Decodable { let id: Int }
        let input = Input(entry_date: date, entry_time: time, title: name, location_name: name, location_lat: latitude, location_lng: longitude, story: story.isEmpty ? nil : story)
        let created: Created = try await request("POST", "api/journeys/\(journeyID)/entries", body: JSONEncoder().encode(input))
        return created.id
    }

    func create() async throws -> JourneyDestination {
        guard let tripID = session.tripID, let title = session.tripTitle else {
            throw JourneyError.message("Choose an active trip in Waypoint first.")
        }
        struct Input: Encodable { let title: String; let trip_ids: [Int] }
        struct Created: Decodable { let id: Int }
        let created: Created = try await request("POST", "api/journeys", body: JSONEncoder().encode(Input(title: title, trip_ids: [tripID])))
        guard let destination = try await detail(created.id).destination(for: session) else {
            throw JourneyError.message("The Journey was created, but could not be linked to this trip. Open TREK to check it.")
        }
        return destination
    }

    func contains(_ photo: JourneyUpload.Photo, in destination: JourneyDestination) async throws -> Bool {
        let gallery = try await detail(destination.id).gallery
        for item in gallery where item.filePath != nil && !destination.knownPhotoIDs.contains(item.photoId) {
            let bytes = try await data("GET", "api/photos/\(item.photoId)/original")
            if JourneyStore.checksum(bytes) == photo.checksum { return true }
        }
        return false
    }

    func request<Response: Decodable>(_ method: String, _ path: String, body: Data? = nil) async throws -> Response {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Response.self, from: await data(method, path, body: body))
    }

    func data(_ method: String, _ path: String, body: Data? = nil, contentType: String = "application/json") async throws -> Data {
        let current = JourneySession.load().flatMap { $0.scope == session.scope ? $0 : nil } ?? session
        var request = try JourneyStore.request(path, session: current)
        request.httpMethod = method
        request.httpBody = body
        if body != nil { request.setValue(contentType, forHTTPHeaderField: "Content-Type") }
        request.timeoutInterval = 20
        let (data, response) = try await Self.transport.data(for: request)
        if let response = response as? HTTPURLResponse { JourneySession.renew(from: response, for: session.scope) }
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        if status == 401 { throw JourneyError.signIn }
        if status == 404 { throw JourneyError.message("Journey is unavailable. Check that the addon is enabled and you still have access in TREK.") }
        guard (200..<300).contains(status) else {
            struct Failure: Decodable { let error: String? }
            let message = (try? JSONDecoder().decode(Failure.self, from: data))?.error
            throw JourneyError.message(message ?? "TREK is unavailable. Try again when your server is reachable.")
        }
        return data
    }
}

private final class JourneyRedirectGuard: NSObject, URLSessionTaskDelegate {
    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping @Sendable (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}
