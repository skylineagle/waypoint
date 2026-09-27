import SwiftUI

struct BalanceBar: View {
    let share: Double

    var body: some View {
        GeometryReader { proxy in
            let half = proxy.size.width / 2
            let length = half * min(abs(share), 1)
            ZStack(alignment: .leading) {
                Capsule().fill(Color.trekSecondaryFill)
                Capsule()
                    .fill(share >= 0 ? Color.trekSuccess : Color.trekDanger)
                    .frame(width: length)
                    .offset(x: share >= 0 ? half : half - length)
            }
        }
        .frame(height: 6)
        .accessibilityHidden(true)
    }
}
