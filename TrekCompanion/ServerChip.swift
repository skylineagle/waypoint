import SwiftUI

struct ServerChip: View {
    let host: String

    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(Color.trekSuccess)
                .frame(width: 7, height: 7)
            Text(host)
                .font(.poppins(13, relativeTo: .footnote))
                .foregroundStyle(Color.trekTextSecondary)
        }
        .padding(.leading, 10)
        .padding(.trailing, 12)
        .padding(.vertical, 6)
        .background(Color.trekCard, in: .capsule)
        .overlay(Capsule().strokeBorder(Color.trekBorder))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Server \(host)")
    }
}
