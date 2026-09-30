import SwiftUI

struct TodoQuickAddRow: View {
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
            TextField("New to-do", text: $name)
                .font(.poppins(14))
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
