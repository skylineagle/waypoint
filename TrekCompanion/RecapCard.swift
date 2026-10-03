import SwiftUI

struct RecapCard: View {
    let onStart: () -> Void

    var body: some View {
        Button(action: onStart) {
            HStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(LinearGradient(colors: [.trekIndigo, .trekViolet], startPoint: .topLeading, endPoint: .bottomTrailing), in: .rect(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Recap this day in Journey")
                        .font(.poppins(15, .semibold, relativeTo: .subheadline))
                        .foregroundStyle(Color.trekText)
                    Text("Pick photos and a few words for each place")
                        .font(.poppins(13, relativeTo: .footnote))
                        .foregroundStyle(Color.trekMuted)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.trekFaint)
            }
            .padding(12)
            .background(Color.trekCard, in: .rect(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.trekIndigo.opacity(0.5)))
        }
        .buttonStyle(.plain)
    }
}
