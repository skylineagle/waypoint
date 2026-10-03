import SwiftUI

struct TripActivityBody: View {
    let state: TripActivityAttributes.ContentState
    var isCompact = false

    var body: some View {
        if let here = state.here {
            ActivityHereView(state: state, here: here, isCompact: isCompact)
        } else if let journey = state.journey {
            ActivityJourneyView(journey: journey, isCompact: isCompact)
        } else {
            ActivityHeadingView(state: state, isCompact: isCompact)
        }
    }
}
