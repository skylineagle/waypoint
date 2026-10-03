import Foundation
import Observation
import UIKit
import UniformTypeIdentifiers

struct SharedPhoto {
    let file: URL
    let taken: JourneyPhoto.Taken
    var stop: JourneyStop?
}

struct QueuedPhoto: Identifiable {
    let id = UUID()
    let raw: URL
    let thumbnail: UIImage?
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
    var receipts: [ShareReceipt] = []
    var queue: [QueuedPhoto] = []
    var processedCount = 0
    var trip: JourneyAPI.TripInfo?
    var tripCurrency: String? { trip?.currency }
    var addedReceiptFiles: Set<URL> = []
    var addedExpenseCount: Int { addedReceiptFiles.count }
    var stops: [JourneyStop] = []
    var isLoading = true
    var isSending = false
    var isSaved = false
    var errorMessage: String?
    var uploadError: String?
    var expenses: [ShareReceipt] { receipts.filter(\.isExpense) }
    var journeyPhotos: [SharedPhoto] {
        let expenseFiles = Set(expenses.map(\.file))
        return photos.filter { !expenseFiles.contains($0.file) && !isOutsideTrip($0) }
    }
    var outsideTripPhotos: [SharedPhoto] {
        let receiptFiles = Set(receipts.map(\.file))
        return photos.filter { !receiptFiles.contains($0.file) && isOutsideTrip($0) }
    }
    var files: [URL] { journeyPhotos.map(\.file) }
    var canSend: Bool {
        !isLoading && !isSending && errorMessage == nil && !(files.isEmpty && expenses.isEmpty)
            && (files.isEmpty || selection.selected != nil) && expenses.allSatisfy(\.canAdd)
    }
    var sendLabel: String {
        let expenseLabel = expenses.isEmpty ? nil : "Add \(expenses.count) \(expenses.count == 1 ? "expense" : "expenses")"
        let photoLabel = files.isEmpty ? nil : "Send \(self.photoLabel)"
        let label = [expenseLabel, photoLabel].compactMap(\.self).joined(separator: " · ")
        return label.isEmpty ? "Nothing to send" : label
    }
    var groups: [ShareGroup] {
        let photos = journeyPhotos
        let placed = Dictionary(grouping: photos.compactMap { photo in photo.stop.map { (stop: $0, file: photo.file) } }) { $0.stop.id }
            .values
            .map { ShareGroup(day: $0[0].stop.entryDate, stop: $0[0].stop, files: $0.map(\.file)) }
            .sorted { $0.sortKey < $1.sortKey }
        let unplaced = Dictionary(grouping: photos.filter { $0.stop == nil }) { $0.taken.day ?? "" }
            .map { ShareGroup(day: $0.key.isEmpty ? nil : $0.key, stop: nil, files: $0.value.map(\.file)) }
            .sorted { $0.sortKey < $1.sortKey }
        return placed + unplaced
    }
    var unplacedCount: Int { journeyPhotos.filter { $0.stop == nil }.count }
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
                queue.append(QueuedPhoto(raw: raw, thumbnail: JourneyPhoto.thumbnail(raw)))
            }
            sessionScope = JourneySession.load()?.scope
            if let session = JourneySession.load(), let tripID = session.tripID {
                trip = try? await JourneyAPI(session: session).trip(tripID)
            }
            await selection.load()
            await loadStops()
            for item in queue {
                let taken = JourneyPhoto.taken(item.raw)
                let prepared = try JourneyPhoto.prepare(item.raw, in: directory)
                try? FileManager.default.removeItem(at: item.raw)
                if let details = await ReceiptDetector.details(of: prepared) {
                    await receipts.append(receipt(prepared, details: details))
                }
                photos.append(SharedPhoto(file: prepared, taken: taken, stop: JourneyStop.nearest(to: taken, in: stops)))
                processedCount += 1
            }
        } catch { errorMessage = error.localizedDescription }
    }

    func matchStops() async {
        await loadStops()
        for index in photos.indices { photos[index].stop = JourneyStop.nearest(to: photos[index].taken, in: stops) }
    }

    private func loadStops() async {
        stops = []
        if let destination = selection.selected, let session = JourneySession.load() {
            stops = (try? await JourneyAPI(session: session).stops(in: destination.id)) ?? []
        }
    }

    func assign(_ group: ShareGroup, to stop: JourneyStop) {
        for index in photos.indices where group.files.contains(photos[index].file) { photos[index].stop = stop }
    }

    func stops(on day: String?) -> [JourneyStop] {
        stops.filter { $0.entryDate == day }.sorted { ($0.entryTime ?? "") < ($1.entryTime ?? "") }
    }

    func send() async {
        guard canSend, !isSaved else { return }
        isSending = true
        defer { isSending = false }
        do {
            guard let session = JourneySession.load() else { throw JourneyError.signIn }
            guard session.scope == sessionScope else {
                throw JourneyError.message("Your active trip changed. Close this sheet and share again to review the new destination.")
            }
            try await addExpenses(with: session)
            guard !files.isEmpty else {
                isSaved = true
                return
            }
            guard let destination = selection.selected, destination.scope == session.scope,
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

    private func addExpenses(with session: JourneySession) async throws {
        let pending = expenses.filter { !addedReceiptFiles.contains($0.file) }
        guard !pending.isEmpty else { return }
        guard let tripID = session.tripID else { throw JourneyError.message("Choose an active trip in Waypoint first.") }
        let api = JourneyAPI(session: session)
        let meID = try await api.myID()
        let memberIDs = (try? await api.memberIDs(tripID)) ?? [meID]
        for receipt in pending {
            let expenseID = try await api.addExpense(receipt.input(meID: meID, memberIDs: memberIDs), tripID: tripID)
            addedReceiptFiles.insert(receipt.file)
            do { try await api.uploadReceipt(receipt.file, expenseID: expenseID, tripID: tripID) }
            catch { uploadError = "\(receipt.name) was added, but its receipt image didn't upload." }
        }
    }

    private func isOutsideTrip(_ photo: SharedPhoto) -> Bool {
        guard let days = trip?.days else { return false }
        return !days.contains(photo.taken.day ?? ShareReceipt.dayFormat.format(.now))
    }

    private func receipt(_ file: URL, details: ReceiptDetails) async -> ShareReceipt {
        let name = details.merchant?.capitalized ?? ""
        return ShareReceipt(
            file: file,
            name: name,
            amount: details.total,
            currency: details.currency,
            date: details.date ?? .now,
            category: name.isEmpty ? .other : await ExpenseCategorizer.category(for: name)
        )
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
