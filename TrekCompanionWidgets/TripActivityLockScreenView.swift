import SwiftUI
import WidgetKit

struct TripActivityLockScreenView: View {
    let attributes: TripActivityAttributes
    let state: TripActivityAttributes.ContentState

    private var upNextLine: String {
        guard let leg = state.nextLeg else { return "Up next" }
        return "Up next · \(leg)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(attributes.tripTitle) · \(attributes.dayLabel) · \(attributes.dayTitle)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(1)
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(upNextLine)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.65))
                    HStack(spacing: 8) {
                        if let category = state.nextCategory {
                            StopCategoryBadge(category: category, size: 26)
                        }
                        Text(state.nextName ?? "Day complete")
                            .font(.system(size: 19, weight: .bold))
                            .lineLimit(1)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(state.spentToday).font(.system(size: 17, weight: .bold))
                    Text("today").font(.system(size: 11)).foregroundStyle(.white.opacity(0.55))
                }
            }
            StopProgressBar(done: state.doneCount, total: state.total)
            TripActivityActions(state: state)
        }
        .foregroundStyle(.white)
        .padding(14)
    }
}
