import SwiftUI

struct ReminderKindIcon: View {
    let symbol: String
    let tint: Color

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 28, height: 28)
            .background(tint, in: .rect(cornerRadius: 7))
            .accessibilityHidden(true)
    }
}
