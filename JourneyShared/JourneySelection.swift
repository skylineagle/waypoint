import Foundation
import Observation

@Observable
final class JourneySelection {
    var destinations: [JourneyDestination] = []
    var selected: JourneyDestination?
    var isLoading = false
    var errorMessage: String?
    private(set) var hasLoaded = false

    init() {
        if let session = JourneySession.load() { selected = JourneyDestination.saved(for: session) }
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            guard let session = JourneySession.load() else { throw JourneyError.signIn }
            guard session.tripID != nil else { throw JourneyError.message("Choose an active trip in Waypoint first.") }
            let saved = JourneyDestination.saved(for: session)
            destinations = try await JourneyAPI(session: session).destinations()
            selected = destinations.first { $0.id == (selected?.id ?? saved?.id) }
                ?? (destinations.count == 1 ? destinations.first : nil)
            selected?.save()
            errorMessage = nil
            hasLoaded = true
        } catch {
            if case JourneyError.signIn = error { selected = nil }
            errorMessage = error.localizedDescription
        }
    }

    func select(_ destination: JourneyDestination) {
        selected = destination
        destination.save()
    }

    func create() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            guard let session = JourneySession.load() else { throw JourneyError.signIn }
            let destination = try await JourneyAPI(session: session).create()
            destinations.append(destination)
            select(destination)
            errorMessage = nil
            hasLoaded = true
        } catch { errorMessage = error.localizedDescription }
    }
}
