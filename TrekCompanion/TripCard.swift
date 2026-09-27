import SwiftUI

struct TripCard: View {
    let trip: Trip
    let isSelected: Bool

    private static let thumbnails: [[Color]] = [
        [.trekIndigo, .trekCyan],
        [Color(hex: 0xD97706), Color(hex: 0xF59E0B)],
        [Color(hex: 0x0D9488), Color(hex: 0x14B8A6)],
        [Color(hex: 0xE11D48), Color(hex: 0xF43F5E)],
        [Color(hex: 0x7C3AED), Color(hex: 0x8B5CF6)],
    ]

    private var details: String {
        [trip.dateRange, trip.currency].compactMap(\.self).joined(separator: " · ")
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: Self.thumbnails[trip.id % Self.thumbnails.count], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(trip.title)
                        .font(.poppins(15, .semibold))
                        .foregroundStyle(Color.trekText)
                    if trip.isHappeningNow {
                        Text("Now")
                            .font(.poppins(11, .semibold, relativeTo: .caption2))
                            .foregroundStyle(Color.trekSuccess)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Color.trekSuccess.opacity(0.14), in: .capsule)
                    }
                }
                Text(details)
                    .font(.poppins(12, relativeTo: .caption))
                    .foregroundStyle(Color.trekMuted)
            }

            Spacer(minLength: 8)

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22))
                .foregroundStyle(isSelected ? Color.trekAccent : Color.trekBorder)
        }
        .padding(12)
        .background(Color.trekCard, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(isSelected ? Color.trekAccent : Color.trekBorder, lineWidth: isSelected ? 2 : 1)
        }
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
