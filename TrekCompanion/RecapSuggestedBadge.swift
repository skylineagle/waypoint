import SwiftUI

struct RecapSuggestedBadge: View {
    var body: some View {
        Label("Not in your plan", systemImage: "sparkle")
            .font(.poppins(11, .semibold, relativeTo: .caption))
            .textCase(.uppercase)
            .foregroundStyle(Color.trekViolet)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(Color.trekViolet.opacity(0.16), in: .capsule)
            .overlay(Capsule().stroke(Color.trekViolet.opacity(0.35)))
    }
}
