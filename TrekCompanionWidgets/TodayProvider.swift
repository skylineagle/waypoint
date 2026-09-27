import WidgetKit

nonisolated struct TodayEntry: TimelineEntry {
    let date: Date
    let snapshot: TodaySnapshot?
}

nonisolated struct TodayProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: .now, snapshot: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        completion(TodayEntry(date: .now, snapshot: context.isPreview ? .preview : TodaySnapshot.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        let entry = TodayEntry(date: .now, snapshot: TodaySnapshot.load())
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(30 * 60))))
    }
}
