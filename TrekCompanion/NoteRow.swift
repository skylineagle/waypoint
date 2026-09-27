import SwiftUI

struct NoteRow: View {
    let note: DayNote

    private static let lucideSymbols: [String: String] = [
        "FileText": "doc.text", "StickyNote": "note.text", "Info": "info.circle", "AlertTriangle": "exclamationmark.triangle",
        "Clock": "clock", "Utensils": "fork.knife", "Coffee": "cup.and.saucer", "Car": "car", "Train": "tram",
        "Plane": "airplane", "Hotel": "bed.double", "Camera": "camera", "ShoppingBag": "bag", "Ticket": "ticket",
        "MapPin": "mappin", "Star": "star", "Heart": "heart", "Luggage": "suitcase.rolling", "Bus": "bus",
    ]

    private var symbol: String? {
        guard let icon = note.icon, icon.count > 2 else { return note.icon == nil ? "note.text" : nil }
        return Self.lucideSymbols[icon] ?? "note.text"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Group {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.trekMuted)
                } else if let icon = note.icon {
                    Text(icon).font(.system(size: 13))
                }
            }
            .frame(width: 26, height: 26)
            .background(Color.trekBackground)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(note.text)
                    .font(.poppins(13, .semibold, relativeTo: .footnote))
                    .foregroundStyle(Color.trekTextSecondary)
                if let detail = note.time, !detail.isEmpty {
                    Text(detail)
                        .font(.poppins(12, relativeTo: .caption))
                        .foregroundStyle(Color.trekMuted)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(Color.trekSecondaryFill.opacity(0.6), in: .rect(cornerRadius: 12))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Note: \(note.text)")
    }
}
