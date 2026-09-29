import SwiftUI

struct DayStatusBadge: View {
    let text: String
    let isLive: Bool

    var body: some View {
        HStack(spacing: 5) {
            if isLive {
                Circle()
                    .fill(Color.trekSuccess)
                    .frame(width: 6, height: 6)
            }
            Text(text.uppercased())
                .font(.poppins(9.5, .bold, relativeTo: .caption2))
                .tracking(0.8)
        }
        .foregroundStyle(isLive ? Color.trekSuccess : Color.trekTextSecondary)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .glassEffect(isLive ? .regular.tint(.trekSuccess.opacity(0.18)) : .regular, in: .capsule)
    }
}
