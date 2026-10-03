import ActivityKit
import SwiftUI
import WidgetKit

struct TripActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TripActivityAttributes.self) { context in
            TripActivityLockScreenView(attributes: context.attributes, state: context.state)
                .activityBackgroundTint(Color.widgetNight.opacity(0.85))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.here == nil && context.state.journey != nil ? "" : (["Stop \(context.state.position) of \(context.state.total)", context.state.here == nil ? context.state.nextLeg : nil].compactMap(\.self).joined(separator: " · ")))
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 8)
                        .padding(.top, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ActivityCornerTime(state: context.state)
                        .font(.caption.bold())
                        .padding(.trailing, 8)
                        .padding(.top, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    TripActivityBody(state: context.state, isCompact: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.top, 4)
                        .padding(.bottom, 6)
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Text("\(context.state.position)")
                        .font(.caption2.bold())
                        .foregroundStyle(.black)
                        .frame(width: 18, height: 18)
                        .background(Color.widgetDone, in: .circle)
                    Text(context.state.here?.name ?? context.state.journey.map { $0.title } ?? context.state.nextName ?? "Done")
                        .font(.caption.bold())
                        .lineLimit(1)
                        .frame(maxWidth: 70)
                }
            } compactTrailing: {
                ActivityCompactTime(state: context.state).font(.caption.bold())
            } minimal: {
                Text("\(context.state.position)")
                    .font(.caption2.bold())
                    .foregroundStyle(.black)
                    .frame(width: 18, height: 18)
                    .background(Color.widgetDone, in: .circle)
            }
            .widgetURL(WidgetLinks.today)
        }
    }
}
