import SwiftUI

struct ActivityCompactTime: View {
    let state: TripActivityAttributes.ContentState

    var body: some View {
        if let here = state.here {
            Text(here.since, style: .timer)
                .foregroundStyle(Color(red: 0x86 / 255, green: 0xEF / 255, blue: 0xAC / 255))
                .frame(maxWidth: 44)
        } else if let journey = state.journey, journey.isOnBoard(at: .now), let arrives = journey.arrives {
            Text(arrives, format: .dateTime.hour().minute())
        } else if let leaveBy = state.journey?.leaveBy ?? state.journey?.departs ?? state.leaveBy {
            Text(timerInterval: Date.now...max(leaveBy, .now), countsDown: true)
                .foregroundStyle(ActivityUrgency(leaveBy: leaveBy).tint)
                .frame(maxWidth: 44)
        } else {
            Text(state.spentToday)
        }
    }
}
