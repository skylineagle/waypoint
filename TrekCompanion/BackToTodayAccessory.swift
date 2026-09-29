import SwiftUI

struct BackToTodayAccessory: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: "arrow.uturn.backward")
                .font(.poppins(14, .semibold, relativeTo: .subheadline))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.trekText)
    }
}
