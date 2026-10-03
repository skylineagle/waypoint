import SwiftUI

struct ActivityJourneyView: View {
    let journey: TripJourney
    var isCompact = false

    private static let green = Color(red: 0x86 / 255, green: 0xEF / 255, blue: 0xAC / 255)

    var body: some View {
        let now = Date.now
        let isOnBoard = journey.isOnBoard(at: now)
        VStack(alignment: .leading, spacing: isCompact ? 6 : 8) {
            HStack(spacing: 10) {
                endpoint(time: journey.departs, place: journey.from, alignment: .leading)
                    .opacity(isOnBoard ? 0.6 : 1)
                JourneyProgressLine(departs: journey.departs, arrives: journey.arrives, now: now)
                endpoint(time: journey.arrives, place: journey.to, alignment: .trailing)
            }
            HStack(spacing: 6) {
                if isOnBoard {
                    if let arrives = journey.arrives, arrives > now {
                        ActivityChip(tint: Self.green) { LeaveCountdown(leaveBy: arrives, verb: "Arrives") }
                    }
                } else if let leaveBy = journey.leaveBy, isCountingDown(to: leaveBy, now: now) {
                    ActivityChip(tint: ActivityUrgency(leaveBy: leaveBy).tint) { LeaveCountdown(leaveBy: leaveBy) }
                } else if journey.leaveBy == nil, isCountingDown(to: journey.departs, now: now) {
                    ActivityChip(tint: ActivityUrgency(leaveBy: journey.departs).tint) { LeaveCountdown(leaveBy: journey.departs, verb: "Departs") }
                }
            }
            TripActivityActions(isCompact: isCompact, buttons: isOnBoard ? [.ticket(journey.ticketURL), .expense] : [.ticket(journey.ticketURL), .directions(journey.directionsURL), .expense])
        }
    }

    private func isCountingDown(to date: Date, now: Date) -> Bool {
        date.timeIntervalSince(now) <= LeaveCountdown.countdownLimit
    }

    private func endpoint(time: Date?, place: String?, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 0) {
            Text(time.map { $0.formatted(.dateTime.hour().minute()) } ?? "--:--")
                .font(.system(size: isCompact ? 20 : 24, weight: .heavy))
                .monospacedDigit()
            Text(place ?? " ")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(1)
        }
    }
}
