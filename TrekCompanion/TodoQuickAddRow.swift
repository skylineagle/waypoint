import SwiftUI

struct TodoQuickAddRow: View {
    var placeholder = "New to-do"
    let onAdd: (String) async throws -> Void
    @State private var name = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
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
                .disabled(isSaving)
        }
        .padding(.vertical, 3)
        .alert("Couldn’t add item", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func add() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !isSaving else { return }
        isSaving = true
        Task {
            defer { isSaving = false }
            do {
                try await onAdd(trimmed)
                name = ""
                isFocused = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
