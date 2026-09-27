import SwiftUI

struct MemberChip: View {
    let userID: Int?
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let userID {
                    MemberAvatar(userID: userID, name: name, size: 22)
                }
                Text(name)
                    .font(.poppins(13, .semibold, relativeTo: .subheadline))
            }
            .foregroundStyle(isSelected ? Color.trekAccentText : Color.trekTextSecondary)
            .padding(.leading, userID == nil ? 12 : 5)
            .padding(.trailing, 12)
            .padding(.vertical, 5)
            .frame(minHeight: 34)
            .background(isSelected ? Color.trekAccent : Color.trekCard, in: .capsule)
            .overlay(Capsule().strokeBorder(isSelected ? Color.clear : Color.trekBorder))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
