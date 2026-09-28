import ActivityKit
import Foundation

nonisolated enum TripLiveActivity {
    private static let stoppedDayKey = "live-activity-stopped-day"

    static var isRunning: Bool {
        Activity<TripActivityAttributes>.activities.contains { $0.activityState == .active || $0.activityState == .stale }
    }

    private static var wasDismissed: Bool {
        Activity<TripActivityAttributes>.activities.contains { $0.activityState == .dismissed }
    }

    static func start(with snapshot: TodaySnapshot) async {
        AppGroup.defaults.removeObject(forKey: stoppedDayKey)
        await sync(with: snapshot, canStart: true)
    }

    static func stop(for snapshot: TodaySnapshot) async {
        AppGroup.defaults.set(dayKey(snapshot), forKey: stoppedDayKey)
        for activity in Activity<TripActivityAttributes>.activities { await activity.end(nil, dismissalPolicy: .immediate) }
    }

    static func startAutomatically(with snapshot: TodaySnapshot) async {
        if wasDismissed { AppGroup.defaults.set(dayKey(snapshot), forKey: stoppedDayKey) }
        guard AppSettings.isLiveActivityEnabled, !isRunning,
              AppGroup.defaults.string(forKey: stoppedDayKey) != dayKey(snapshot)
        else { return }
        await sync(with: snapshot, canStart: true)
    }

    static func sync(with snapshot: TodaySnapshot?, canStart: Bool = false) async {
        let running = Activity<TripActivityAttributes>.activities
        guard let snapshot, snapshot.countdown == nil, !snapshot.stops.isEmpty else {
            for activity in running { await activity.end(nil, dismissalPolicy: .immediate) }
            return
        }
        let content = ActivityContent(state: snapshot.activityState, staleDate: endOfDay)
        let current = running.filter { ($0.activityState == .active || $0.activityState == .stale) && $0.attributes.dayLabel == snapshot.dayLabel && $0.attributes.tripTitle == snapshot.tripTitle }
        for activity in running where !current.contains(where: { $0.id == activity.id }) {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        if let activity = current.first {
            await activity.update(content)
        } else if canStart, ActivityAuthorizationInfo().areActivitiesEnabled {
            let attributes = TripActivityAttributes(tripTitle: snapshot.tripTitle, dayLabel: snapshot.dayLabel, dayTitle: snapshot.dayTitle)
            _ = try? Activity.request(attributes: attributes, content: content)
        }
    }

    private static func dayKey(_ snapshot: TodaySnapshot) -> String {
        "\(snapshot.tripID)-\(snapshot.date)"
    }

    private static var endOfDay: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: .now)) ?? .now
    }
}
