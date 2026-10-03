import AppIntents

struct NextStopIntent: AppIntent {
    static let title: LocalizedStringResource = "What's Next"
    static let description = IntentDescription("Tells you the next stop on today's itinerary.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let snapshot = TodaySnapshot.load(), snapshot.date == ExpenseDate.today || snapshot.countdown != nil else {
            return .result(dialog: "Open Waypoint to load today's plan.", view: nil as NextStopSnippet?)
        }
        if let countdown = snapshot.countdown {
            return .result(dialog: "\(snapshot.tripTitle) starts in \(countdown).", view: nil as NextStopSnippet?)
        }
        guard let next = snapshot.next else {
            return .result(dialog: "That's everything for today.", view: nil as NextStopSnippet?)
        }
        let leg = next.leg.map { ", \($0)" } ?? ""
        return .result(dialog: "Next is \(next.name)\(leg).", view: NextStopSnippet(snapshot: snapshot, stop: next))
    }
}
