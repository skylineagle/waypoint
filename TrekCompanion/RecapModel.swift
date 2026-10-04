import CoreLocation
import Foundation
import Observation
import Photos

struct RecapPlace: Identifiable {
    let id: Int
    var name: String?
    let notes: String?
    let time: String?
    var entryID: Int?
    let latitude: Double?
    let longitude: Double?
    var isSuggested = false
    var candidates: [RecapCandidate]?
    var chosen: RecapCandidate?
    var photoIDs: [String] = []
    var selected: Set<String> = []
    var text = ""
    var draft = ""
    var isDrafted = false
    var isDrafting = false
    var isSkipped = false

    var hasContent: Bool { !selected.isEmpty || !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(stop: TripStop, entry: JourneyStop?) {
        id = stop.id
        name = stop.place.name
        notes = stop.notes
        time = (entry?.entryTime ?? stop.assignmentTime).map { String($0.prefix(5)) }
        entryID = entry?.id
        latitude = stop.place.lat
        longitude = stop.place.lng
    }

    init(suggestedID: Int, spot: [RecapMatcher.Photo], entry: JourneyStop?) {
        let locations = spot.compactMap(\.location)
        id = suggestedID
        name = entry?.name
        notes = nil
        time = spot.first.map { String(TripReminderEvents.wallClock.string(from: $0.date).suffix(5)) }
        entryID = entry?.id
        latitude = locations.map(\.coordinate.latitude).reduce(0, +) / Double(max(locations.count, 1))
        longitude = locations.map(\.coordinate.longitude).reduce(0, +) / Double(max(locations.count, 1))
        isSuggested = true
    }
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
        places = day.stops.map { stop in RecapPlace(stop: stop, entry: entries.first { $0.sourceAssignmentId == stop.id }) }
        await match(entries: entries)
        phase = .reviewing
    }

    private func match(entries: [JourneyStop]) async {
        let planned = places.map(matchPlace)
        let photos = assets.map(Self.photo)
        let assetsByID = Dictionary(uniqueKeysWithValues: assets.map { ($0.localIdentifier, $0) })
        var fromCamera: [RecapMatcher.Photo] = []
        for photo in photos where RecapMatcher.isUnplanned(photo, among: planned) {
            if let asset = assetsByID[photo.id], await RecapLibrary.isFromCamera(asset) { fromCamera.append(photo) }
        }
        let spots = RecapMatcher.spots(of: fromCamera)
        var unclaimed = entries.filter { $0.sourceAssignmentId == nil }
        let suggested = spots.enumerated().map { offset, spot in
            let center = RecapPlace(suggestedID: -(offset + 1), spot: spot, entry: nil)
            let entry = JourneyStop.nearest(to: JourneyPhoto.Taken(day: day.date, latitude: center.latitude, longitude: center.longitude), in: unclaimed)
            unclaimed.removeAll { $0.id == entry?.id }
            return RecapPlace(suggestedID: center.id, spot: spot, entry: entry)
        }
        var byPlace = Dictionary(uniqueKeysWithValues: zip(suggested.map(\.id), spots))
        let spotted = Set(fromCamera.map(\.id))
        let everyPlace = planned + suggested.map(matchPlace)
        for photo in photos where !spotted.contains(photo.id) {
            if let id = RecapMatcher.placeID(of: photo, among: everyPlace) { byPlace[id, default: []].append(photo) }
        }
        let moment = { (place: RecapPlace) in
            place.time.flatMap { TripReminderEvents.moment(self.day.date, time: $0) } ?? byPlace[place.id]?.map(\.date).min()
        }
        for place in suggested {
            guard let at = moment(place) else { continue }
            places.insert(place, at: RecapMatcher.insertionIndex(of: at, among: places.map(moment)))
        }
        for index in places.indices {
            let matched = byPlace[places[index].id] ?? []
            places[index].photoIDs = matched.map(\.id)
            places[index].selected = Set(RecapMatcher.picks(from: matched))
        }
    }

    private func matchPlace(_ place: RecapPlace) -> RecapMatcher.Place {
        RecapMatcher.Place(
            id: place.id,
            latitude: place.latitude,
            longitude: place.longitude,
            arrival: place.time.flatMap { TripReminderEvents.moment(day.date, time: $0) }
        )
    }

    private static func photo(_ asset: PHAsset) -> RecapMatcher.Photo {
        RecapMatcher.Photo(
            id: asset.localIdentifier,
            date: asset.creationDate ?? .distantPast,
            latitude: asset.location?.coordinate.latitude,
            longitude: asset.location?.coordinate.longitude,
            isFavorite: asset.isFavorite
        )
    }

    func findPlacesIfNeeded() async {
        let current = index
        guard places[current].isSuggested, places[current].candidates == nil, let coordinate = places[current].coordinate else { return }
        let found = await RecapPlaceFinder.nearby(coordinate)
        places[current].candidates = found
        if found.count == 1, places[current].name == nil { choose(found[0], at: current) }
    }

    func choose(_ candidate: RecapCandidate) {
        choose(candidate, at: index)
    }

    private func choose(_ candidate: RecapCandidate, at position: Int) {
        places[position].chosen = candidate
        places[position].name = candidate.name
        guard places[position].text == places[position].draft else { return }
        places[position].text = ""
        places[position].isDrafted = false
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
        guard places.indices.contains(current), !places[current].isDrafted, let name = places[current].name else { return }
        places[current].isDrafted = true
        guard RecapWriter.isAvailable else { return }
        places[current].isDrafting = true
        defer { places[current].isDrafting = false }
        let draft = await RecapWriter.draft(place: name, notes: places[current].notes)
        guard places[current].name == name else { return }
        places[current].draft = draft
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
            guard let date = day.date else { throw JourneyError.message("This day has no date.") }
            let api = JourneyAPI(session: session)
            let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: directory) }
            var files: [URL] = []
            var entryIDs: [URL: Int] = [:]
            for place in kept {
                let story = place.text.trimmingCharacters(in: .whitespacesAndNewlines)
                var entryID = place.entryID
                if let existing = entryID {
                    if !story.isEmpty { try await api.write(story: story, toEntry: existing) }
                } else if place.isSuggested, let name = place.name,
                          let latitude = place.chosen?.latitude ?? place.latitude, let longitude = place.chosen?.longitude ?? place.longitude {
                    entryID = try await api.createEntry(in: destination.id, date: date, time: place.time, name: name, latitude: latitude, longitude: longitude, story: story)
                }
                for asset in assets where place.selected.contains(asset.localIdentifier) {
                    let file = try await RecapLibrary.export(asset, to: directory)
                    files.append(file)
                    entryIDs[file] = entryID
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
