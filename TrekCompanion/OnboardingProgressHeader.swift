import SwiftUI

struct OnboardingProgressHeader: View {
    let stepNumber: Int
    let total: Int
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(spacing: 14) {
                Button("Back", systemImage: "chevron.left", action: onBack)
                    .labelStyle(.iconOnly)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.trekText)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)

                HStack(spacing: 6) {
                    ForEach(1...total, id: \.self) { index in
                        Capsule()
                            .fill(index <= stepNumber ? Color.trekAccent : Color.trekBorder)
                            .frame(height: 4)
                    }
                }
                .accessibilityElement()
                .accessibilityLabel("Step \(stepNumber) of \(total)")
            }

            Text("Step \(stepNumber) of \(total)")
                .font(.poppins(13, .medium, relativeTo: .footnote))
                .foregroundStyle(Color.trekMuted)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .animation(.smooth, value: stepNumber)
    }
}
