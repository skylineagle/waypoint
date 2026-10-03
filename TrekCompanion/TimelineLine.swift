import SwiftUI

struct TimelineLine: View {
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear.frame(height: isFirst ? 18 : 0)
            Rectangle().fill(Color.trekBorder).frame(width: 1.5)
            Color.clear.frame(height: isLast ? 18 : 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 28.25)
        .accessibilityHidden(true)
    }
}
