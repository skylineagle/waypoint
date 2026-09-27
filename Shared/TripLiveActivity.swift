import ActivityKit
import Foundation

nonisolated enum TripLiveActivity {
    static func sync(with snapshot: TodaySnapshot?) async {
        let running = Activity<TripActivityAttributes>.activities
        guard AppSettings.isLiveActivityEnabled, let snapshot, snapshot.countdown == nil, !snapshot.stops.isEmpty else {
            for activity in running { await activity.end(nil, dismissalPolicy: .immediate) }
            return
        }
        let content = ActivityContent(state: snapshot.activityState, staleDate: endOfDay)
        let current = running.filter { $0.attributes.dayLabel == snapshot.dayLabel && $0.attributes.tripTitle == snapshot.tripTitle }
        for activity in running where !current.contains(where: { $0.id == activity.id }) {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        if let activity = current.first {
            await activity.update(content)
        } else if ActivityAuthorizationInfo().areActivitiesEnabled {
            let attributes = TripActivityAttributes(tripTitle: snapshot.tripTitle, dayLabel: snapshot.dayLabel, dayTitle: snapshot.dayTitle)
            _ = try? Activity.request(attributes: attributes, content: content)
        }
    }

    private static var endOfDay: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: .now)) ?? .now
    }
}
