import SwiftUI

struct StepHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.poppins(28, .bold, relativeTo: .largeTitle))
                .tracking(-0.5)
                .foregroundStyle(Color.trekText)
                .accessibilityAddTraits(.isHeader)
            if let subtitle {
                Text(subtitle)
                    .font(.poppins(15, relativeTo: .subheadline))
                    .foregroundStyle(Color.trekMuted)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
