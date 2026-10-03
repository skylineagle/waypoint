import Foundation
import Observation
import Photos

struct RecapPlace: Identifiable {
    let stop: TripStop
    let entryID: Int?
    let time: String?
    var photoIDs: [String] = []
    var selected: Set<String> = []
    var text = ""
    var isDrafted = false
    var isDrafting = false
    var isSkipped = false

    var id: Int { stop.id }
    var hasContent: Bool { !selected.isEmpty || !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}

struct RecapSummary {
    let photoCount: Int
    let placeCount: Int
    let skippedCount: Int
}

@Observable
final class RecapModel {
    enum Phase {
        case loading
        case failed(String)
        case reviewing
        case publishing
        case done(RecapSummary)
    }

    let day: TripDay
    let dayNumber: Int
    private(set) var phase = Phase.loading
    private(set) var assets: [PHAsset] = []
    var places: [RecapPlace] = []
    var index = 0

    init(day: TripDay, dayNumber: Int) {
        self.day = day
        self.dayNumber = dayNumber
    }

    var isLast: Bool { index == places.count - 1 }

    func load() async {
        guard await RecapLibrary.requestAccess() else {
            phase = .failed("Allow Waypoint to see your photos in Settings to recap this day.")
            return
        }
        guard let session = JourneySession.load() else {
            phase = .failed(JourneyError.signIn.localizedDescription)
            return
        }
        let selection = JourneySelection()
        await selection.load()
        guard let destination = selection.selected else {
            phase = .failed(selection.errorMessage ?? "Choose a Journey for this trip in Settings first.")
            return
        }
        let entries = (try? await JourneyAPI(session: session).stops(in: destination.id)) ?? []
        guard let start = ExpenseDate.date(from: day.date), let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else {
            phase = .failed("This day has no date.")
            return
        }
        assets = RecapLibrary.assets(from: start, to: end)
        places = day.stops.map { stop in
            let entry = entries.first { $0.sourceAssignmentId == stop.id }
            return RecapPlace(stop: stop, entryID: entry?.id, time: (entry?.entryTime ?? stop.assignmentTime).map { String($0.prefix(5)) })
        }
        match()
        phase = .reviewing
    }

    private func match() {
        let matchPlaces = places.map { place in
            RecapMatcher.Place(
                id: place.id,
                latitude: place.stop.place.lat,
                longitude: place.stop.place.lng,
                arrival: place.time.flatMap { TripReminderEvents.moment(day.date, time: $0) }
            )
        }
        let photos = assets.map { asset in
            RecapMatcher.Photo(
                id: asset.localIdentifier,
                date: asset.creationDate ?? .distantPast,
                latitude: asset.location?.coordinate.latitude,
                longitude: asset.location?.coordinate.longitude,
                isFavorite: asset.isFavorite
            )
        }
        let byPlace = Dictionary(grouping: photos) { RecapMatcher.placeID(of: $0, among: matchPlaces) ?? -1 }
        for index in places.indices {
            let matched = byPlace[places[index].id] ?? []
            places[index].photoIDs = matched.map(\.id)
            places[index].selected = Set(RecapMatcher.picks(from: matched))
        }
    }

    /// This place's photos first, then the rest of the day in time order. Photos picked for another place are left out.
    func orderedAssets(for place: RecapPlace) -> [PHAsset] {
        let own = Set(place.photoIDs)
        let taken = places.filter { $0.id != place.id && !$0.isSkipped }.reduce(into: Set<String>()) { $0.formUnion($1.selected) }
        let available = assets.filter { !taken.contains($0.localIdentifier) }
        return available.filter { own.contains($0.localIdentifier) } + available.filter { !own.contains($0.localIdentifier) }
    }

    func toggle(_ assetID: String) {
        if places[index].selected.contains(assetID) {
            places[index].selected.remove(assetID)
        } else {
            places[index].selected.insert(assetID)
        }
    }

    func draftIfNeeded() async {
        let current = index
        guard places.indices.contains(current), !places[current].isDrafted else { return }
        places[current].isDrafted = true
        guard RecapWriter.isAvailable else { return }
        places[current].isDrafting = true
        defer { places[current].isDrafting = false }
        let place = places[current]
        let draft = await RecapWriter.draft(place: place.stop.place.name, notes: place.stop.notes)
        if places[current].text.isEmpty { places[current].text = draft }
    }

    func next(skipping: Bool) async {
        places[index].isSkipped = skipping
        if isLast {
            await publish()
        } else {
            index += 1
        }
    }

    func back() {
        index = max(index - 1, 0)
    }

    private func publish() async {
        phase = .publishing
        let kept = places.filter { !$0.isSkipped && $0.hasContent }
        do {
            guard let session = JourneySession.load() else { throw JourneyError.signIn }
            guard let destination = JourneySelection().selected else { throw JourneyError.message("Choose a Journey for this trip in Settings first.") }
            let api = JourneyAPI(session: session)
            let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: directory) }
            var files: [URL] = []
            var entryIDs: [URL: Int] = [:]
            for place in kept {
                for asset in assets where place.selected.contains(asset.localIdentifier) {
                    let file = try await RecapLibrary.export(asset, to: directory)
                    files.append(file)
                    entryIDs[file] = place.entryID
                }
                let story = place.text.trimmingCharacters(in: .whitespacesAndNewlines)
                if let entryID = place.entryID, !story.isEmpty {
                    try await api.write(story: story, toEntry: entryID)
                }
            }
            if !files.isEmpty {
                _ = try JourneyStore.shared().enqueue(files, entryIDs: entryIDs, destination: destination)
                try? JourneyUploader.instance(JourneyUploader.appIdentifier).start()
            }
            DayRecap.markDone(day.id)
            phase = .done(RecapSummary(photoCount: files.count, placeCount: kept.count, skippedCount: places.count - kept.count))
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}
