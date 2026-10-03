import SwiftUI

struct TodoQuickAddRow: View {
    var placeholder = "New to-do"
    let onAdd: (String) async -> Void
    @State private var name = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: "plus")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.trekFaint)
                .frame(width: 22)
                .accessibilityHidden(true)
            TextField("", text: $name)
                .background(alignment: .leading) {
                    if name.isEmpty {
                        Text(placeholder).foregroundStyle(Color.trekFaint)
                    }
                }
                .font(.poppins(14))
                .accessibilityLabel(placeholder)
                .foregroundStyle(Color.trekText)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(add)
        }
        .padding(.vertical, 3)
    }

    private func add() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        name = ""
        isFocused = true
        Task { await onAdd(trimmed) }
    }
}
