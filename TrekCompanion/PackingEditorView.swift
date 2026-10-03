import SwiftUI

struct PackingEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let item: PackingItem?
    let categories: [String]
    let onSave: (PackingInput) async throws -> Void
    let onDelete: () async -> Void

    @State private var name: String
    @State private var category: String?
    @State private var quantity: Int
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var isNamingCategory = false
    @State private var newCategoryName = ""
    @State private var contentHeight: CGFloat = 420
    @State private var isConfirmingDelete = false

    init(
        item: PackingItem?,
        category: String?,
        categories: [String],
        onSave: @escaping (PackingInput) async throws -> Void,
        onDelete: @escaping () async -> Void
    ) {
        self.item = item
        self.categories = categories
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: item?.name ?? "")
        _category = State(initialValue: item?.category ?? category)
        _quantity = State(initialValue: item?.quantity ?? 1)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !isSaving
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item == nil ? "New item" : "Edit item")
                .font(.poppins(15, .semibold, relativeTo: .headline))
                .foregroundStyle(Color.trekText)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 4)
            TrekTextField(symbol: "suitcase", placeholder: "What to pack?", text: $name, focusOnAppear: item == nil, accessibilityLabel: "Name")
            details
            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle")
                    .font(.poppins(13, relativeTo: .footnote))
                    .foregroundStyle(Color.trekDanger)
            }
            Button(item == nil ? "Add item" : "Save item", action: save)
                .buttonStyle(TrekButtonStyle())
                .disabled(!canSave)
                .padding(.top, 8)
            if item != nil {
                Button("Delete item", role: .destructive) { isConfirmingDelete = true }
                    .font(.poppins(15, .semibold))
                    .foregroundStyle(Color.trekDanger)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .onGeometryChange(for: CGFloat.self, of: \.size.height) { contentHeight = $0 }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.trekBackground)
        .presentationDetents([.height(contentHeight)])
        .presentationDragIndicator(.visible)
        .confirmationDialog("Delete this item?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Delete Item", role: .destructive) {
                Task {
                    await onDelete()
                    dismiss()
                }
            }
        }
        .alert("New category", isPresented: $isNamingCategory) {
            TextField("Category name", text: $newCategoryName)
            Button("Cancel", role: .cancel) {}
            Button("Add") {
                let trimmed = newCategoryName.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty { category = trimmed }
            }
        }
    }

    private var details: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                detailLabel("Category", symbol: "square.stack")
                Menu {
                    Button("No category") { category = nil }
                    ForEach(Array(Set(categories + [category].compactMap(\.self))).sorted(), id: \.self) { name in
                        Button(name) { category = name }
                    }
                    Divider()
                    Button("New category…", systemImage: "plus") {
                        newCategoryName = ""
                        isNamingCategory = true
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(category ?? "No category").lineLimit(1)
                        Image(systemName: "chevron.up.chevron.down").font(.system(size: 10, weight: .semibold))
                    }
                    .font(.poppins(14))
                    .foregroundStyle(Color.trekMuted)
                }
            }
            .frame(minHeight: 50)
            Divider().overlay(Color.trekDivider)
            HStack(spacing: 10) {
                detailLabel("Quantity", symbol: "number")
                Text("\(quantity)")
                    .font(.poppins(14))
                    .foregroundStyle(Color.trekMuted)
                    .contentTransition(.numericText())
                quantityButton("Decrease quantity", symbol: "minus", step: -1)
                quantityButton("Increase quantity", symbol: "plus", step: 1)
            }
            .frame(minHeight: 50)
        }
        .padding(.horizontal, 14)
        .trekCard()
    }

    private func detailLabel(_ title: String, symbol: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 15))
                .foregroundStyle(Color.trekFaint)
                .frame(width: 20)
                .accessibilityHidden(true)
            Text(title)
                .font(.poppins(14))
                .foregroundStyle(Color.trekText)
            Spacer(minLength: 8)
        }
    }

    private func quantityButton(_ label: String, symbol: String, step: Int) -> some View {
        Button {
            withAnimation(.smooth) { quantity += step }
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.trekText)
                .frame(width: 32, height: 32)
                .background(Color.trekFaint.opacity(0.2), in: .circle)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .disabled(!(1...99).contains(quantity + step))
        .sensoryFeedback(.selection, trigger: quantity)
    }

    private func save() {
        guard canSave else { return }
        let input = PackingInput(name: name.trimmingCharacters(in: .whitespaces), category: category, quantity: quantity, bagId: item?.bagId)
        isSaving = true
        errorMessage = nil
        Task {
            defer { isSaving = false }
            do {
                try await onSave(input)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
