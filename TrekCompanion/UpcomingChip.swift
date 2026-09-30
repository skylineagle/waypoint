import SwiftUI

struct UpcomingChip: View {
    let daysUntil: Int

    private var countdown: String {
        daysUntil == 1 ? "Tomorrow" : "In \(daysUntil) days"
    }

    var body: some View {
        VStack(spacing: 1) {
            Text("TRIP STARTS")
                .font(.poppins(9.5, .semibold, relativeTo: .caption2))
                .tracking(0.6)
                .foregroundStyle(Color.trekMuted)
            Text(countdown)
                .font(.poppins(20, .bold, relativeTo: .title3))
                .foregroundStyle(Color.trekText)
        }
        .frame(width: 120, height: 60)
        .accessibilityElement(children: .combine)
    }
}
