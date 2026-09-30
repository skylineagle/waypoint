import SwiftUI

struct NoteRow: View {
    let note: DayNote
    @State private var isExpanded = false

    private var tint: Color {
        guard let hex = note.color?.trimmingCharacters(in: CharacterSet(charactersIn: "#")), let value = UInt32(hex, radix: 16) else { return .trekMuted }
        return Color(hex: value)
    }

    private var description: String? {
        guard let time = note.time, !time.isEmpty else { return nil }
        return time
    }

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
                        .foregroundStyle(tint)
                } else if let icon = note.icon {
                    Text(icon).font(.system(size: 13))
                }
            }
            .frame(width: 26, height: 26)
            .background(tint.opacity(note.color == nil ? 0 : 0.14), in: .rect(cornerRadius: 8))
            .background(Color.trekBackground)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(note.text)
                        .font(.poppins(13, .semibold, relativeTo: .footnote))
                        .foregroundStyle(Color.trekTextSecondary)
                    Spacer(minLength: 4)
                    if description != nil {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.trekMuted)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }
                if isExpanded, let description {
                    NoteMarkdown(text: description)
                        .font(.poppins(12, relativeTo: .caption))
                        .foregroundStyle(Color.trekMuted)
                        .transition(.opacity)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(Color.trekSecondaryFill.opacity(0.6), in: .rect(cornerRadius: 12))
            .overlay(alignment: .leading) {
                if note.color != nil {
                    UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 12).fill(tint).frame(width: 3)
                }
            }
            .contentShape(.rect)
            .onTapGesture {
                guard description != nil else { return }
                withAnimation(.snappy) { isExpanded.toggle() }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Note: \(note.text)")
        .accessibilityHint(description == nil ? "" : isExpanded ? "Collapse details" : "Show details")
        .accessibilityAddTraits(description == nil ? [] : .isButton)
    }
}
