import SwiftUI

struct SplitFigure: View {
    let title: String
    let amount: String
    let footnote: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.poppins(10, .bold, relativeTo: .caption2))
                .tracking(0.9)
                .foregroundStyle(Color.trekFaint)
            Text(amount)
                .font(.poppins(22, .bold, relativeTo: .title2))
                .foregroundStyle(tint)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(footnote)
                .font(.poppins(12, relativeTo: .caption))
                .foregroundStyle(Color.trekMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
