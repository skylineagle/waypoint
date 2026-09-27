import SwiftUI

struct TrekButtonStyle: ButtonStyle {
    enum Kind {
        case primary
        case secondary
        case onNight
    }

    var kind: Kind = .primary
    @Environment(\.isEnabled) private var isEnabled

    private var background: Color {
        switch kind {
        case .primary: .trekAccent
        case .secondary: .trekSecondaryFill
        case .onNight: Color(hex: 0xE4E4E7)
        }
    }

    private var foreground: Color {
        switch kind {
        case .primary: .trekAccentText
        case .secondary: .trekTextSecondary
        case .onNight: Color(hex: 0x09090B)
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.poppins(16, .semibold))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(background, in: .rect(cornerRadius: 12))
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.35)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}
