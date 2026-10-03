import SwiftUI

struct ActivityCornerTime: View {
    let state: TripActivityAttributes.ContentState

    private var isHeading: Bool { state.here == nil && state.journey == nil }

    var body: some View {
        if isHeading, let leaveBy = state.leaveBy {
            LeaveCountdown(leaveBy: leaveBy)
                .foregroundStyle(ActivityUrgency(leaveBy: leaveBy).tint)
        } else if isHeading, let bookedAt = state.nextBookedAt {
            Text("Booked \(bookedAt, format: .dateTime.hour().minute())")
                .foregroundStyle(ActivityHeadingView.violet)
        } else {
            Text("\(state.spentToday) today")
        }
    }
}
