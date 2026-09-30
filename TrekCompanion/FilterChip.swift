import SwiftUI

struct FilterChip: View {
    let title: String
    var color: Color?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let color {
                    Circle().fill(color).frame(width: 7, height: 7)
                }
                Text(title)
            }
            .font(.poppins(12, .semibold, relativeTo: .caption))
            .foregroundStyle(isSelected ? Color.trekAccentText : Color.trekTextSecondary)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(isSelected ? Color.trekAccent : Color.trekCard, in: .capsule)
            .overlay(Capsule().strokeBorder(isSelected ? Color.clear : Color.trekBorder))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
