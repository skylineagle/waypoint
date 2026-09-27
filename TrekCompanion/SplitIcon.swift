import SwiftUI

struct SplitIcon: View {
    let symbol: String
    let tint: Color

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(tint)
            .frame(width: 30, height: 30)
            .background(tint.opacity(0.14), in: .rect(cornerRadius: 10))
            .accessibilityHidden(true)
    }
}
