import SwiftUI
import WidgetKit

struct SpentTodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "SpentTodayWidget", provider: TodayProvider()) { entry in
            SpentTodayWidgetView(snapshot: entry.snapshot)
                .widgetURL(WidgetLinks.addExpense)
        }
        .configurationDisplayName("Spent today")
        .description("Today's trip spending. Tap to add an expense.")
        .supportedFamilies([.systemSmall])
    }
}
