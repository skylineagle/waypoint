import CoreText
import SwiftUI
import UIKit

extension Color {
    static let trekNight = Color(hex: 0x070C1A)
    static let trekBackground = Color(light: 0xF9FAFB, dark: 0x09090B)
    static let trekCard = Color(light: 0xFFFFFF, dark: 0x18181C)
    static let trekInput = Color(light: 0xFFFFFF, dark: 0x202026)
    static let trekBorder = Color(light: 0xE5E7EB, dark: 0x2C2C34)
    static let trekDivider = Color(light: 0xF3F4F6, dark: 0x24242A)
    static let trekText = Color(light: 0x111827, dark: 0xF4F4F5)
    static let trekTextSecondary = Color(light: 0x374151, dark: 0xD4D4D8)
    static let trekMuted = Color(light: 0x6B7280, dark: 0xA1A1AA)
    static let trekFaint = Color(light: 0x9CA3AF, dark: 0x7A7A85)
    static let trekAccent = Color(light: 0x111827, dark: 0xE4E4E7)
    static let trekAccentText = Color(light: 0xFFFFFF, dark: 0x09090B)
    static let trekSecondaryFill = Color(light: 0x000000, lightAlpha: 0.06, dark: 0xFFFFFF, darkAlpha: 0.1)
    static let trekHeroTop = Color(light: 0x15151A, dark: 0x2A2560)
    static let trekHeroBottom = Color(light: 0x15151A, dark: 0x16161C)
    static let trekHeroEdge = Color(light: 0xFFFFFF, lightAlpha: 0, dark: 0xFFFFFF, darkAlpha: 0.1)
    static let trekSuccess = Color(light: 0x16A34A, dark: 0x4ADE80)
    static let trekDanger = Color(light: 0xDC2626, dark: 0xF87171)
    static let trekWarning = Color(light: 0xD97706, dark: 0xFBBF24)
    static let trekIndigo = Color(hex: 0x4F46E5)
    static let trekCyan = Color(hex: 0x06B6D4)
    static let trekViolet = Color(hex: 0x8B5CF6)

    init(hex: UInt32, alpha: Double = 1) {
        self.init(uiColor: UIColor(hex: hex, alpha: alpha))
    }

    init(light: UInt32, lightAlpha: Double = 1, dark: UInt32, darkAlpha: Double = 1) {
        let lightColor = UIColor(hex: light, alpha: lightAlpha)
        let darkColor = UIColor(hex: dark, alpha: darkAlpha)
        self.init(uiColor: UIColor { @Sendable traits in
            traits.userInterfaceStyle == .dark ? darkColor : lightColor
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32, alpha: Double) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

extension Font {
    static func poppins(_ size: CGFloat, _ weight: Font.Weight = .regular, relativeTo style: Font.TextStyle = .body) -> Font {
        let name = switch weight {
        case .bold, .heavy, .black: "Poppins-Bold"
        case .semibold: "Poppins-SemiBold"
        case .medium: "Poppins-Medium"
        default: "Poppins-Regular"
        }
        return .custom(name, size: size, relativeTo: style)
    }

    static func museoModerno(_ size: CGFloat) -> Font {
        .custom("MuseoModernoRoman-Bold", size: size, relativeTo: .largeTitle)
    }
}

enum TrekFonts {
    static func register() {
        let urls = Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? []
        CTFontManagerRegisterFontURLs(urls as CFArray, .process, true, nil)
    }
}
