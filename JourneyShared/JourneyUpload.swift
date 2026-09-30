import Foundation

nonisolated struct JourneyUpload: Codable, Identifiable {
    enum State: String, Codable { case queued, uploading, failed, uncertain, signIn }

    struct Photo: Codable, Identifiable {
        let id: UUID
        let fileName: String
        let checksum: String
        var entryID: Int?
        var state: State = .queued
        var message: String?
        var sessionIdentifier: String?
        var taskIdentifier: Int?
    }

    let id: UUID
    let destination: JourneyDestination
    let createdAt: Date
    var photos: [Photo]
}
