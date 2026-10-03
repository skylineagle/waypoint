import SwiftUI

struct JourneyLegLabel: View {
    let reservation: Reservation

    private static let tint = Color(hex: 0x8B74E0)

    private var schedule: String {
        [reservation.time, reservation.endTime].compactMap(\.self).joined(separator: " → ")
    }

    private var duration: String? {
        guard let start = minutes(reservation.time), let end = minutes(reservation.endTime) else { return nil }
        let total = (end - start + 1440) % 1440
        return Duration.seconds(total * 60).formatted(.units(allowed: [.hours, .minutes], width: .narrow))
    }

    private var details: String {
        [duration, reservation.confirmationNumber.map { "Conf. \($0)" }].compactMap(\.self).joined(separator: " · ")
    }

    var body: some View {
        BookingButton(reservation: reservation) { icon in
            HStack(spacing: 0) {
                Capsule()
                    .fill(Self.tint)
                    .frame(width: 3.5)
                    .padding(.leading, 11.25)
                    .padding(.trailing, 21.25)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: reservation.symbol)
                            .foregroundStyle(Self.tint)
                        Text(reservation.title)
                            .font(.poppins(12.5, .semibold))
                            .foregroundStyle(Color.trekText)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        Text(schedule)
                            .font(.poppins(12, .semibold))
                            .monospacedDigit()
                            .foregroundStyle(Color.trekText)
                        if icon.hasFiles || icon.isOpening { icon }
                    }
                    .font(.system(size: 12, weight: .semibold))
                    if !details.isEmpty {
                        Text(details)
                            .font(.poppins(11, relativeTo: .caption2))
                            .foregroundStyle(Color.trekMuted)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(Self.tint.opacity(0.1), in: .rect(cornerRadius: 12))
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func minutes(_ time: String?) -> Int? {
        guard let parts = time?.split(separator: ":").compactMap({ Int($0) }), parts.count == 2 else { return nil }
        return parts[0] * 60 + parts[1]
    }
}
