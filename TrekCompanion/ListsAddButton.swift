import SwiftUI

struct ListsAddButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.body.weight(.semibold))
                .frame(minWidth: 28, minHeight: 28)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .controlSize(.regular)
        .tint(Color.trekAccent)
        .accessibilityLabel(label)
        .padding(.trailing, 16)
        .padding(.bottom, 12)
    }
}
