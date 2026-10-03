import SwiftUI

struct PackingBagChip: View {
    let bag: PackingBag

    private var tint: Color {
        guard let hex = bag.color?.replacingOccurrences(of: "#", with: ""),
              hex.count == 6, let value = UInt32(hex, radix: 16)
        else { return .trekMuted }
        return Color(hex: value)
    }

    var body: some View {
        Label(bag.name, systemImage: "bag")
            .font(.poppins(11, .medium, relativeTo: .caption))
            .foregroundStyle(Color.trekTextSecondary)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(tint.opacity(0.16), in: .rect(cornerRadius: 6))
            .overlay {
                RoundedRectangle(cornerRadius: 6).strokeBorder(tint.opacity(0.3), lineWidth: 0.5)
            }
            .environment(\.layoutDirection, bag.name.isRightToLeft ? .rightToLeft : .leftToRight)
            .accessibilityLabel("Bag: \(bag.name)")
    }
}
