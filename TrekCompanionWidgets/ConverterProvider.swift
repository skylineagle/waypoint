import WidgetKit

nonisolated struct ConverterEntry: TimelineEntry {
    let date: Date
    let state: ConverterState?
}

nonisolated struct ConverterProvider: TimelineProvider {
    private static let preview = ConverterState(tripTitle: "Thailand", tripCurrency: "THB", displayCurrency: "EUR", rate: 0.0262, entry: "500", lastKeyAt: nil)

    func placeholder(in context: Context) -> ConverterEntry {
        ConverterEntry(date: .now, state: Self.preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (ConverterEntry) -> Void) {
        completion(ConverterEntry(date: .now, state: context.isPreview ? Self.preview : ConverterState.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ConverterEntry>) -> Void) {
        completion(Timeline(entries: [ConverterEntry(date: .now, state: ConverterState.load())], policy: .never))
    }
}
