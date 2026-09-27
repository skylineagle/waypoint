import SwiftUI

struct MemberAvatar: View {
    let userID: Int
    let name: String
    var size: CGFloat = 28

    private static let gradients: [[Color]] = [
        [Color(hex: 0x6366F1), Color(hex: 0x8B5CF6)],
        [Color(hex: 0xEC4899), Color(hex: 0xF43F5E)],
        [Color(hex: 0x14B8A6), Color(hex: 0x06B6D4)],
        [Color(hex: 0xF59E0B), Color(hex: 0xF97316)],
        [Color(hex: 0x22C55E), Color(hex: 0x10B981)],
    ]

    var body: some View {
        Text(name.prefix(1).uppercased())
            .font(.poppins(size * 0.42, .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(colors: Self.gradients[userID % Self.gradients.count], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: .circle
            )
            .accessibilityHidden(true)
    }
}
