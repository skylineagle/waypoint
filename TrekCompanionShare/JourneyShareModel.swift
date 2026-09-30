import Foundation
import Observation
import UniformTypeIdentifiers

struct SharedPhoto {
    let file: URL
    let taken: JourneyPhoto.Taken
    var stop: JourneyStop?
}

struct ShareGroup: Identifiable {
    let day: String?
    let stop: JourneyStop?
    let files: [URL]
    var sortKey: String { "\(day ?? "")|\(stop?.entryTime ?? "")|\(String(format: "%09d", stop?.id ?? 0))" }
    var id: String { stop.map { "stop-\($0.id)" } ?? "day-\(day ?? "unknown")" }
}

@Observable
final class JourneyShareModel {
    let selection = JourneySelection()
    var photos: [SharedPhoto] = []
    var stops: [JourneyStop] = []
    var isLoading = true
    var isSending = false
    var isSaved = false
    var errorMessage: String?
    var uploadError: String?
    var files: [URL] { photos.map(\.file) }
    var groups: [ShareGroup] {
        let placed = Dictionary(grouping: photos.compactMap { photo in photo.stop.map { (stop: $0, file: photo.file) } }) { $0.stop.id }
            .values
            .map { ShareGroup(day: $0[0].stop.entryDate, stop: $0[0].stop, files: $0.map(\.file)) }
            .sorted { $0.sortKey < $1.sortKey }
        let unplaced = Dictionary(grouping: photos.filter { $0.stop == nil }) { $0.taken.day ?? "" }
            .map { ShareGroup(day: $0.key.isEmpty ? nil : $0.key, stop: nil, files: $0.value.map(\.file)) }
            .sorted { $0.sortKey < $1.sortKey }
        return placed + unplaced
    }
    var unplacedCount: Int { photos.filter { $0.stop == nil }.count }
    var photoLabel: String { "\(files.count) \(files.count == 1 ? "photo" : "photos")" }
    private var sessionScope: String?
    private let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)

    func load(_ attachments: [NSItemProvider]) async {
        defer { isLoading = false }
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            guard !attachments.isEmpty else { throw JourneyError.message("Choose photos from your gallery to share.") }
            for attachment in attachments {
                guard let type = attachment.registeredTypeIdentifiers.first(where: { UTType($0)?.conforms(to: .image) == true }) else {
                    throw JourneyError.message("Waypoint shares still photos. Remove videos and other files from this selection.")
                }
                let raw = try await copy(attachment, type: type)
                let taken = JourneyPhoto.taken(raw)
                let prepared = try JourneyPhoto.prepare(raw, in: directory)
                try? FileManager.default.removeItem(at: raw)
                photos.append(SharedPhoto(file: prepared, taken: taken))
            }
            sessionScope = JourneySession.load()?.scope
            await selection.load()
            await matchStops()
        } catch { errorMessage = error.localizedDescription }
    }

    func matchStops() async {
        stops = []
        if let destination = selection.selected, let session = JourneySession.load() {
            stops = (try? await JourneyAPI(session: session).stops(in: destination.id)) ?? []
        }
        for index in photos.indices { photos[index].stop = JourneyStop.nearest(to: photos[index].taken, in: stops) }
    }

    func assign(_ group: ShareGroup, to stop: JourneyStop) {
        for index in photos.indices where group.files.contains(photos[index].file) { photos[index].stop = stop }
    }

    func stops(on day: String?) -> [JourneyStop] {
        stops.filter { $0.entryDate == day }.sorted { ($0.entryTime ?? "") < ($1.entryTime ?? "") }
    }

    func send() {
        guard !isSending, !isSaved, !isLoading, errorMessage == nil,
              let destination = selection.selected else { return }
        isSending = true
        defer { isSending = false }
        do {
            guard let session = JourneySession.load() else { throw JourneyError.signIn }
            guard session.scope == sessionScope, destination.scope == session.scope,
                  destination.tripID == session.tripID else {
                throw JourneyError.message("Your active trip changed. Close this sheet and share again to review the new destination.")
            }
            let entryIDs = Dictionary(uniqueKeysWithValues: photos.compactMap { photo in photo.stop.map { (photo.file, $0.id) } })
            _ = try JourneyStore.shared().enqueue(files, entryIDs: entryIDs, destination: destination)
            isSaved = true
            do { try JourneyUploader.instance(JourneyUploader.shareIdentifier).start() }
            catch { uploadError = "Your photos are saved. Open Waypoint to start uploading them." }
        } catch { errorMessage = error.localizedDescription }
    }

    func cleanUp() { try? FileManager.default.removeItem(at: directory) }

    private func copy(_ provider: NSItemProvider, type: String) async throws -> URL {
        let target = directory.appending(path: UUID().uuidString)
        return try await withCheckedThrowingContinuation { continuation in
            provider.loadFileRepresentation(forTypeIdentifier: type) { source, error in
                do {
                    if let error { throw error }
                    guard let source else { throw JourneyError.message("Couldn't read this photo. Download it in Photos and try again.") }
                    try FileManager.default.copyItem(at: source, to: target)
                    continuation.resume(returning: target)
                } catch { continuation.resume(throwing: error) }
            }
        }
    }
}
