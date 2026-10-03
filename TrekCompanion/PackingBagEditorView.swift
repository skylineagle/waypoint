import SwiftUI

struct PackingBagEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let onCreate: (String) async throws -> Void

    @State private var name = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Name the bag, then add it to this item.")
                        .font(.poppins(14))
                        .foregroundStyle(Color.trekMuted)
                    TrekTextField(symbol: "bag", placeholder: "Bag name", text: $name, focusOnAppear: true, accessibilityLabel: "Bag name")
                    if let errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.circle")
                            .font(.poppins(13, relativeTo: .footnote))
                            .foregroundStyle(Color.trekDanger)
                    }
                    Button(isSaving ? "Creating bag…" : "Create & select bag", action: create)
                        .buttonStyle(TrekButtonStyle())
                        .disabled(trimmedName.isEmpty || isSaving)
                }
                .padding(16)
            }
            .background(Color.trekBackground)
            .navigationTitle("New bag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(isSaving)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(isSaving)
    }

    private func create() {
        guard !trimmedName.isEmpty, !isSaving else { return }
        let name = trimmedName
        isSaving = true
        errorMessage = nil
        Task {
            defer { isSaving = false }
            do {
                try await onCreate(name)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
