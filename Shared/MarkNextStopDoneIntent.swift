import AppIntents
import WidgetKit

nonisolated struct MarkNextStopDoneIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Mark Next Stop Done"
    static let description = IntentDescription("Marks the next stop of today's Trek plan as done.")

    func perform() async throws -> some IntentResult {
        guard let snapshot = TodaySnapshot.load(), let next = snapshot.current else { return .result() }
        snapshot.markDone(next.id)
        await TripLiveActivity.sync(with: snapshot)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
