import SwiftUI

struct ActivityHeadingView: View {
    let state: TripActivityAttributes.ContentState
    var isCompact = false

    static let violet = Color(red: 0xC8 / 255, green: 0xBB / 255, blue: 0xFF / 255)

    private var upNextLine: String {
        guard let leg = state.nextLeg else { return "Up next" }
        return "Up next · \(leg)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 6 : 8) {
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    if !isCompact {
                        Text(upNextLine)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.65))
                    }
                    HStack(spacing: 8) {
                        if let category = state.nextCategory {
                            StopCategoryBadge(category: category, size: 26)
                        }
                        Text(state.nextName ?? "Day complete")
                            .font(.system(size: isCompact ? 17 : 19, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                Spacer(minLength: 8)
                if !isCompact {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(state.spentToday).font(.system(size: 17, weight: .bold))
                        Text("today").font(.system(size: 11)).foregroundStyle(.white.opacity(0.55))
                    }
                }
            }
            if !isCompact, state.leaveBy != nil || state.nextBookedAt != nil {
                HStack(spacing: 6) {
                    if let leaveBy = state.leaveBy {
                        ActivityChip(tint: ActivityUrgency(leaveBy: leaveBy).tint) { LeaveCountdown(leaveBy: leaveBy) }
                    }
                    if let bookedAt = state.nextBookedAt {
                        ActivityChip(tint: Self.violet) { Text("Booked \(bookedAt, format: .dateTime.hour().minute())") }
                    }
                }
            }
            if !isCompact {
                StopProgressBar(done: state.doneCount, total: state.total)
            }
            TripActivityActions(isCompact: isCompact, buttons: [.ticket(state.nextTicketURL), .directions(state.directionsURL), .done(state.nextName != nil), .expense])
        }
    }
}
