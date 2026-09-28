import SwiftUI

struct ShortcutStatusCard: View {
    let check: ShortcutCheck

    private var title: String {
        check == .found ? "Shortcut is ready" : "Add the shortcut"
    }

    private var message: LocalizedStringKey {
        switch check {
        case .idle: "Tap **Add Shortcut** in Shortcuts, then **◀ Waypoint** at the top left to come back."
        case .found: "Your first payment may ask once to **Allow** it."
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            badge
            Text(title)
                .font(.poppins(17, .semibold, relativeTo: .headline))
                .foregroundStyle(Color.trekText)
            Text(message)
                .font(.poppins(13, relativeTo: .footnote))
                .foregroundStyle(Color.trekMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.trekCard, in: .rect(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.trekBorder))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        .accessibilityElement(children: .combine)
        .animation(.smooth, value: check)
    }

    @ViewBuilder
    private var badge: some View {
        switch check {
        case .found:
            badgeTile(symbol: "checkmark", fill: .trekSuccess, foreground: .white)
        case .idle:
            badgeTile(symbol: "plus.square", fill: .trekAccent, foreground: .trekAccentText)
        }
    }

    private func badgeTile(symbol: String, fill: Color, foreground: Color) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 28, weight: .semibold))
            .foregroundStyle(foreground)
            .frame(width: 64, height: 64)
            .background(fill, in: .rect(cornerRadius: 18))
            .accessibilityHidden(true)
    }
}
