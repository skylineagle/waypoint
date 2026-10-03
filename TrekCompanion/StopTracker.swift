import CoreLocation
import WidgetKit

final class StopTracker: NSObject, CLLocationManagerDelegate {
    static let shared = StopTracker()
    static let doneChanged = Notification.Name("stop-tracker-done")

    private static let visitKey = "stop-visit"
    private let manager = CLLocationManager()

    static var dwell: TimeInterval {
        #if DEBUG
        let override = UserDefaults.standard.double(forKey: "StopDwellSeconds")
        if override > 0 { return override }
        #endif
        return 2 * 60
    }

    private var visit: StopVisit? {
        get { UserDefaults.standard.data(forKey: Self.visitKey).flatMap { try? JSONDecoder().decode(StopVisit.self, from: $0) } }
        set { UserDefaults.standard.set(newValue.flatMap { try? JSONEncoder().encode($0) }, forKey: Self.visitKey) }
    }

    func start() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        sync(isActive: false)
    }

    func sync(isActive: Bool) {
        guard places(in: TodaySnapshot.load()).contains(where: { !$0.isDone }) else {
            manager.stopMonitoringVisits()
            manager.stopUpdatingLocation()
            return
        }
        if manager.authorizationStatus == .notDetermined, isActive {
            manager.requestAlwaysAuthorization()
        }
        manager.startMonitoringVisits()
        if isActive {
            manager.startUpdatingLocation()
        } else {
            manager.stopUpdatingLocation()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        MainActor.assumeIsolated {
            for location in locations { handle(location) }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        let stay = visit.departureDate.timeIntervalSince(visit.arrivalDate)
        let arrival = visit.arrivalDate
        let location = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        let accuracy = visit.horizontalAccuracy
        let hasLeft = visit.departureDate != .distantFuture
        MainActor.assumeIsolated { self.handleVisit(at: location, accuracy: accuracy, arrival: arrival, stay: stay, hasLeft: hasLeft) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {}

    private func places(in snapshot: TodaySnapshot?) -> [StopVisits.Place] {
        guard let snapshot else { return [] }
        let done = snapshot.doneIDs
        return snapshot.stops.compactMap { stop in
            guard let latitude = stop.latitude, let longitude = stop.longitude else { return nil }
            return StopVisits.Place(id: stop.id, latitude: latitude, longitude: longitude, isDone: done.contains(stop.id))
        }
    }

    private func handle(_ location: CLLocation) {
        guard (0...200).contains(location.horizontalAccuracy),
              location.timestamp.timeIntervalSinceNow > -60,
              let snapshot = TodaySnapshot.load()
        else { return }
        Task { await TripLiveActivity.startAutomatically(with: snapshot) }
        let arrival = visit?.since
        let step = StopVisits.step(visit, places: places(in: snapshot), at: location, dwell: Self.dwell)
        visit = step.visit
        let isHereChanged = StopHere.save(step.visit.map { StopHere(stopID: $0.stopID, since: $0.since) })
        if let id = step.done {
            markDone(id, in: snapshot, arrivedAt: arrival ?? location.timestamp)
        } else if isHereChanged {
            Task { await TripLiveActivity.sync(with: snapshot) }
        }
    }

    private func handleVisit(at location: CLLocation, accuracy: CLLocationAccuracy, arrival: Date, stay: TimeInterval, hasLeft: Bool) {
        guard let snapshot = TodaySnapshot.load() else { return }
        Task { await TripLiveActivity.startAutomatically(with: snapshot) }
        let reach = min(max(StopVisits.radius, accuracy), 200)
        guard let id = StopVisits.nearest(to: location, in: places(in: snapshot), within: reach) else { return }
        if !hasLeft {
            if StopHere.save(StopHere(stopID: id, since: arrival)) { Task { await TripLiveActivity.sync(with: snapshot) } }
        } else if stay >= Self.dwell {
            markDone(id, in: snapshot, arrivedAt: arrival)
        } else if StopHere.save(nil) {
            Task { await TripLiveActivity.sync(with: snapshot) }
        }
    }

    private func markDone(_ id: Int, in snapshot: TodaySnapshot, arrivedAt arrival: Date) {
        snapshot.markDone(id)
        stampJourney(id, arrival: arrival)
        NotificationCenter.default.post(name: Self.doneChanged, object: nil)
        Task {
            await TripLiveActivity.sync(with: snapshot)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func stampJourney(_ assignmentID: Int, arrival: Date) {
        guard let session = JourneySession.load() else { return }
        let time = arrival.formatted(.verbatim("\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)", timeZone: .current, calendar: .current))
        Task { try? await JourneyAPI(session: session).stampArrival(assignment: assignmentID, at: time) }
    }
}
