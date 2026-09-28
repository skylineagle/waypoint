import SwiftUI
import WidgetKit

struct ConverterWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ConverterWidget", provider: ConverterProvider()) { entry in
            ConverterWidgetView(state: entry.state)
        }
        .configurationDisplayName("Currency")
        .description("Trip currency to yours. Tap the amount to open the converter.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
