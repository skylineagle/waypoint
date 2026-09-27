import AppIntents
import SwiftUI
import WidgetKit

struct TripActivityActions: View {
    let state: TripActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 8) {
            if let url = state.directionsURL {
                Link(destination: url) { pill("Go", systemImage: "location.fill") }
            }
            if state.nextName != nil {
                Button(intent: MarkNextStopDoneIntent()) { pill("Done", systemImage: "checkmark") }
                    .buttonStyle(.plain)
            }
            Link(destination: WidgetLinks.addExpense) { pill("Expense", systemImage: "plus") }
        }
        .foregroundStyle(.white)
    }

    private func pill(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 12, weight: .semibold))
            .frame(maxWidth: .infinity, minHeight: 32)
            .background(.white.opacity(0.14), in: .capsule)
    }
}
