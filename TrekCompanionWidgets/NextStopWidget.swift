import SwiftUI
import WidgetKit

struct NextStopWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "NextStopWidget", provider: TodayProvider()) { entry in
            NextStopWidgetView(snapshot: entry.snapshot)
                .widgetURL(WidgetLinks.today)
        }
        .configurationDisplayName("Up next")
        .description("Your next stop on today's Trek plan.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
