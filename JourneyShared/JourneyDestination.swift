import Foundation

nonisolated struct JourneyDestination: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let tripID: Int
    let tripTitle: String
    let scope: String
    let knownPhotoIDs: [Int]

    static func saved(for session: JourneySession) -> Self? {
        guard let tripID = session.tripID,
              let data = UserDefaults(suiteName: JourneyStore.group)?.data(forKey: key(session.scope, tripID)),
              let destination = try? JSONDecoder().decode(Self.self, from: data),
              destination.scope == session.scope, destination.tripID == tripID else { return nil }
        return destination
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults(suiteName: JourneyStore.group)?.set(data, forKey: Self.key(scope, tripID))
    }

    private static func key(_ scope: String, _ tripID: Int) -> String { "journey-\(scope)-\(tripID)" }
}

nonisolated struct JourneyDetail: Decodable {
    struct LinkedTrip: Decodable { let tripId: Int }
    struct Photo: Decodable {
        let id: Int
        let photoId: Int
        let filePath: String?
    }

    let id: Int
    let title: String
    let myRole: String?
    let trips: [LinkedTrip]
    let gallery: [Photo]

    func destination(for session: JourneySession) -> JourneyDestination? {
        guard let tripID = session.tripID, let tripTitle = session.tripTitle,
              ["owner", "editor"].contains(myRole ?? ""),
              trips.contains(where: { $0.tripId == tripID }) else { return nil }
        return JourneyDestination(id: id, title: title, tripID: tripID, tripTitle: tripTitle,
                                  scope: session.scope, knownPhotoIDs: gallery.map(\.photoId))
    }
}
