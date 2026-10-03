import SwiftUI
import WidgetKit

struct TripActivityLockScreenView: View {
    let attributes: TripActivityAttributes
    let state: TripActivityAttributes.ContentState

    private var header: String {
        if let journey = state.journey, state.here == nil {
            return [journey.title, journey.confirmation.map { "Conf. \($0)" }].compactMap(\.self).joined(separator: " · ")
        }
        let day = "\(attributes.tripTitle) · \(attributes.dayLabel) · \(attributes.dayTitle)"
        return state.here == nil ? day : "\(day) · \(state.spentToday) today"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(1)
            TripActivityBody(state: state)
        }
        .foregroundStyle(.white)
        .padding(14)
    }
}
