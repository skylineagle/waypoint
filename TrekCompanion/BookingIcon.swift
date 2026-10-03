import SwiftUI

struct BookingIcon: View {
    let hasFiles: Bool
    let isOpening: Bool

    var body: some View {
        if isOpening {
            ProgressView().controlSize(.mini)
        } else {
            Image(systemName: hasFiles ? "paperclip" : "arrow.up.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(hasFiles ? Color(hex: 0x9333EA) : Color.trekFaint)
                .accessibilityLabel(hasFiles ? "Has documents" : "")
        }
    }
}
