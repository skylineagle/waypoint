import SwiftUI

struct PackingProgressBar: View {
    let packed: Int
    let total: Int

    private var fraction: Double {
        total == 0 ? 0 : Double(packed) / Double(total)
    }

    var body: some View {
        Capsule()
            .fill(Color.trekFaint.opacity(0.25))
            .frame(height: 6)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(Color.trekAccent)
                        .frame(width: proxy.size.width * fraction)
                }
            }
            .animation(.smooth, value: fraction)
            .accessibilityElement()
            .accessibilityLabel("\(packed) of \(total) packed")
    }
}
