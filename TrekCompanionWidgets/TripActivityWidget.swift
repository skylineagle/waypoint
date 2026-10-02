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
                    Text("Up next · \(context.state.position) of \(context.state.total)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 8)
                        .padding(.top, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.spentToday) today")
                        .font(.caption.bold())
                        .padding(.trailing, 8)
                        .padding(.top, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            if let category = context.state.nextCategory {
                                StopCategoryBadge(category: category)
                            }
                            Text(context.state.nextName ?? "Day complete")
                                .font(.title3.bold())
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        StopProgressBar(done: context.state.doneCount, total: context.state.total)
                        TripActivityActions(state: context.state)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Text("\(context.state.position)")
                        .font(.caption2.bold())
                        .foregroundStyle(.black)
                        .frame(width: 18, height: 18)
                        .background(Color.widgetDone, in: .circle)
                    Text(context.state.nextName ?? "Done")
                        .font(.caption.bold())
                        .lineLimit(1)
                        .frame(maxWidth: 70)
                }
            } compactTrailing: {
                Text(context.state.spentToday).font(.caption.bold())
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
