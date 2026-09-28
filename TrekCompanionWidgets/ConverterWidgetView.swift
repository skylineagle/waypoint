import SwiftUI
import WidgetKit

struct ConverterWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let state: ConverterState?

    var body: some View {
        Group {
            if let state {
                switch family {
                case .systemLarge: ConverterLargeView(state: state)
                case .systemMedium: ConverterMediumView(state: state)
                default: ConverterSmallView(state: state)
                }
            } else {
                Text("Open Trek once to set up the converter.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .widgetURL(WidgetLinks.converter(amount: state?.amount))
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
