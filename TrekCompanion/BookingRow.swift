import SwiftUI

struct BookingRow: View {
    let reservation: Reservation
    @Environment(\.openURL) private var openURL

    private var details: String {
        var parts: [String] = []
        if let time = reservation.time { parts.append(time) }
        if let confirmation = reservation.confirmationNumber { parts.append("Conf. \(confirmation)") }
        return parts.joined(separator: " · ")
    }

    private var webURL: URL? {
        guard let account = Account.load() else { return nil }
        return URL(string: "\(account.serverURL.absoluteString)/trips/\(reservation.tripId)?tab=\(reservation.webTab)")
    }

    var body: some View {
        Button {
            if let webURL { openURL(webURL) }
        } label: {
            content
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens this booking in TREK")
    }

    private var content: some View {
        HStack(spacing: 11) {
            Image(systemName: reservation.symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: 0x9333EA))
                .frame(width: 34, height: 34)
                .background(Color(hex: 0x9333EA).opacity(0.12), in: .rect(cornerRadius: 10))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(reservation.title)
                    .font(.poppins(13.5, .semibold))
                    .foregroundStyle(Color.trekText)
                    .lineLimit(2)
                if !details.isEmpty {
                    Text(details)
                        .font(.poppins(11.5, relativeTo: .caption))
                        .foregroundStyle(Color.trekMuted)
                        .textSelection(.enabled)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "arrow.up.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.trekFaint)
        }
        .padding(11)
        .trekCard()
        .accessibilityElement(children: .combine)
    }
}
