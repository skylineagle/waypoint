import SwiftUI

struct PackingFoldRow: View {
    let packedCount: Int
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .bold))
                    .rotationEffect(.degrees(isExpanded ? 0 : -90))
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .semibold))
                Text("\(packedCount) packed")
                    .font(.poppins(13, relativeTo: .footnote))
                    .contentTransition(.numericText())
                Spacer(minLength: 0)
            }
            .foregroundStyle(Color.trekMuted)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(packedCount) packed items")
        .accessibilityHint(isExpanded ? "Hides packed items" : "Shows packed items")
    }
}
