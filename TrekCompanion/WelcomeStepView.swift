import SwiftUI

struct WelcomeStepView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Image("TrekLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 58)
                .shadow(color: Color(hex: 0x040814).opacity(0.55), radius: 10, y: 2)
                .accessibilityLabel("TREK")

            Text("your trips. your costs.")
                .font(.museoModerno(30))
                .tracking(-0.6)
                .foregroundStyle(.white)
                .shadow(color: Color(hex: 0x040814).opacity(0.55), radius: 10, y: 2)
                .padding(.top, 14)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text("Every Apple Pay payment on your trip, added to your Trek budget automatically.")
                .font(.poppins(15, relativeTo: .subheadline))
                .foregroundStyle(.white.opacity(0.62))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 12)
                .padding(.horizontal, 12)
            Spacer()
                .frame(maxHeight: 120)

            Button(action: onStart) {
                Label("Get Started", systemImage: "arrow.right")
                    .labelStyle(TrailingIconLabelStyle())
            }
            .buttonStyle(TrekButtonStyle(kind: .onNight))

            Text("Works with your self-hosted TREK")
                .font(.poppins(12, relativeTo: .caption))
                .foregroundStyle(.white.opacity(0.45))
                .padding(.top, 14)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { NightSkyBackground() }
        .preferredColorScheme(.dark)
    }
}
