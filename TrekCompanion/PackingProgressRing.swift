import SwiftUI

struct PackingProgressRing: View {
    let packed: Int
    let total: Int
    let tint: Color

    private var fraction: Double {
        total == 0 ? 0 : Double(packed) / Double(total)
    }

    var body: some View {
        ZStack {
            Circle().stroke(Color.trekFaint.opacity(0.25), lineWidth: 3)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(tint, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 20, height: 20)
        .animation(.smooth, value: fraction)
        .accessibilityHidden(true)
    }
}
