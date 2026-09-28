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
        let location = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        let accuracy = visit.horizontalAccuracy
        let hasLeft = visit.departureDate != .distantFuture
        MainActor.assumeIsolated { self.handleVisit(at: location, accuracy: accuracy, stay: stay, hasLeft: hasLeft) }
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
        let step = StopVisits.step(visit, places: places(in: snapshot), at: location, dwell: Self.dwell)
        visit = step.visit
        if let id = step.done { markDone(id, in: snapshot) }
    }

    private func handleVisit(at location: CLLocation, accuracy: CLLocationAccuracy, stay: TimeInterval, hasLeft: Bool) {
        guard let snapshot = TodaySnapshot.load() else { return }
        Task { await TripLiveActivity.startAutomatically(with: snapshot) }
        guard hasLeft, stay >= Self.dwell else { return }
        let reach = min(max(StopVisits.radius, accuracy), 200)
        if let id = StopVisits.nearest(to: location, in: places(in: snapshot), within: reach) {
            markDone(id, in: snapshot)
        }
    }

    private func markDone(_ id: Int, in snapshot: TodaySnapshot) {
        snapshot.markDone(id)
        NotificationCenter.default.post(name: Self.doneChanged, object: nil)
        Task {
            await TripLiveActivity.sync(with: snapshot)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
