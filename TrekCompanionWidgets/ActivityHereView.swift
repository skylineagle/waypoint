import SwiftUI

struct ActivityHereView: View {
    let state: TripActivityAttributes.ContentState
    let here: TripActivityAttributes.Here
    var isCompact = false

    private static let green = Color(red: 0x86 / 255, green: 0xEF / 255, blue: 0xAC / 255)

    private var thenLine: String? {
        guard let thenName = here.thenName else { return nil }
        guard let leaveBy = here.thenLeaveBy else { return "Next: \(thenName)" }
        return "Next: \(thenName) · leave by \(leaveBy.formatted(.dateTime.hour().minute()))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("You're at")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.65))
                    HStack(spacing: 8) {
                        if let category = here.category {
                            StopCategoryBadge(category: category, size: 26)
                        }
                        Text(here.name)
                            .font(.system(size: isCompact ? 18 : 22, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text("Here").font(.system(size: 12)).foregroundStyle(.white.opacity(0.65))
                    Text(here.since, style: .relative)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Self.green)
                        .multilineTextAlignment(.trailing)
                }
            }
            if let thenLine {
                Text(thenLine)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.65))
                    .lineLimit(1)
            }
            if !isCompact {
                StopProgressBar(done: state.doneCount, total: state.total)
                    .padding(.vertical, 2)
            }
            TripActivityActions(isCompact: isCompact, buttons: [.ticket(here.ticketURL), .done(true), .expense])
        }
    }
}
