import AppIntents

struct WaypointShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: NextStopIntent(),
            phrases: [
                "What's next in \(.applicationName)",
                "What's my next stop in \(.applicationName)",
                "Where to next in \(.applicationName)",
            ],
            shortTitle: "What's Next",
            systemImageName: "point.bottomleft.forward.to.point.topright.scurvepath"
        )
        AppShortcut(
            intent: LogExpenseIntent(),
            phrases: [
                "Log an expense in \(.applicationName)",
                "Add a cost in \(.applicationName)",
            ],
            shortTitle: "Log Expense",
            systemImageName: "creditcard"
        )
    }
}
