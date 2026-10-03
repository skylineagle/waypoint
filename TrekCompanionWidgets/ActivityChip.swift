import SwiftUI

struct ActivityChip<Label: View>: View {
    let tint: Color
    @ViewBuilder let label: Label

    var body: some View {
        label
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tint.opacity(0.18), in: .rect(cornerRadius: 7))
    }
}
