import SwiftUI

struct BookedBadge: View {
    let reservation: Reservation

    var body: some View {
        Text(["Booked", reservation.time].compactMap(\.self).joined(separator: " · ").uppercased())
            .font(.poppins(9.5, .bold, relativeTo: .caption2))
            .tracking(0.5)
            .foregroundStyle(Color(hex: 0xC8BBFF))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(hex: 0x8B74E0).opacity(0.2), in: .rect(cornerRadius: 6))
    }
}
