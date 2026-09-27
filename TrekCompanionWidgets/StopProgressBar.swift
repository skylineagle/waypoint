import SwiftUI

struct StopProgressBar: View {
    let done: Int
    let total: Int
    var track: Color = .white.opacity(0.2)

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<max(total, 1), id: \.self) { index in
                Capsule()
                    .fill(index < done ? Color.widgetDone : track)
                    .frame(height: 4)
            }
        }
    }
}
