import SwiftUI

struct ShortcutStatusCard: View {
    let check: ShortcutCheck

    private var title: String {
        switch check {
        case .idle, .missing: "Add to TREK"
        case .checking: "Checking your shortcut…"
        case .found: "Add to TREK is ready"
        }
    }

    private var message: LocalizedStringKey? {
        switch check {
        case .idle: "Opens Shortcuts. Tap **Add Shortcut**, then come back here."
        case .checking: "Shortcuts may ask once to allow **Add to TREK** — tap **Allow**."
        case .missing: "Not found yet. Add it and keep the name **Add to TREK**."
        case .found: nil
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            badge
            Text(title)
                .font(.poppins(17, .semibold, relativeTo: .headline))
                .foregroundStyle(Color.trekText)
            if let message {
                Text(message)
                    .font(.poppins(13, relativeTo: .footnote))
                    .foregroundStyle(check == .missing ? Color.trekDanger : Color.trekMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
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
        case .checking:
            ProgressView()
                .controlSize(.large)
                .frame(width: 64, height: 64)
        case .found:
            badgeTile(symbol: "checkmark", fill: .trekSuccess, foreground: .white)
        case .idle, .missing:
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
