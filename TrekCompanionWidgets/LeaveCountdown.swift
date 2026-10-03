import SwiftUI

struct LeaveCountdown: View {
    let leaveBy: Date
    var verb = "Leave"

    static let countdownLimit: TimeInterval = 60 * 60

    var body: some View {
        let now = Date.now
        if leaveBy.timeIntervalSince(now) > Self.countdownLimit {
            Text("\(verb) at \(leaveBy, format: .dateTime.hour().minute())")
        } else if leaveBy > now {
            HStack(spacing: 0) {
                Text("\(verb) in ")
                Text(timerInterval: now...leaveBy, countsDown: true)
                    .monospacedDigit()
            }
        } else {
            Text("Late \(max(Int(now.timeIntervalSince(leaveBy) / 60), 1)) min")
        }
    }
}
