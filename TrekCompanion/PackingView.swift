import SwiftUI

enum PackingEditorTarget: Identifiable {
    case new(category: String?)
    case edit(PackingItem)

    var id: String {
        switch self {
        case .new(let category): "new-\(category ?? "")"
        case .edit(let item): "\(item.id)"
        }
    }
}

struct PackingView: View {
    let model: PackingModel
    @State private var editor: PackingEditorTarget?
    @State private var collapsed: Set<String> = []
    @State private var showsPacked: Set<String> = []

    var body: some View {
        List {
            status
            ForEach(model.categories) { category in
                Section {
                    if !collapsed.contains(category.id) {
                        let tint = PackingCategoryStyle(category: category.name).color
                        ForEach(category.unpackedItems) { item in
                            row(for: item, tint: tint)
                        }
                        quickAddRow(category: category.name)
                        if category.packedCount > 0 {
                            packedFoldRow(for: category)
                            if showsPacked.contains(category.id) {
                                ForEach(category.packedItems) { item in
                                    row(for: item, tint: tint)
                                }
                            }
                        }
                    }
                } header: {
                    PackingCategoryHeader(category: category, isCollapsed: collapsed.contains(category.id)) {
                        withAnimation(.smooth) {
                            if collapsed.contains(category.id) { collapsed.remove(category.id) } else { collapsed.insert(category.id) }
                        }
                    }
                }
            }
            if model.items?.isEmpty == true {
                Section { quickAddRow(category: nil) }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(10)
        .environment(\.defaultMinListRowHeight, 40)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .contentMargins(.top, 0, for: .scrollContent)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New packing item", systemImage: "plus") { editor = .new(category: nil) }
            }
        }
        .refreshable { await model.load() }
        .animation(.smooth, value: model.items)
        .task { if model.items == nil { await model.load() } }
        .sheet(item: $editor) { target in
            editorView(for: target)
        }
    }

    @ViewBuilder
    private var status: some View {
        if let message = model.bagErrorMessage {
            Section {
                Label(message, systemImage: "bag.badge.questionmark")
                    .font(.poppins(13, relativeTo: .footnote))
                    .foregroundStyle(Color.trekMuted)
            }
        }
        if let errorMessage = model.errorMessage {
            Section {
                Label(errorMessage, systemImage: "wifi.exclamationmark")
                    .font(.poppins(13, relativeTo: .footnote))
                    .foregroundStyle(Color.trekDanger)
            }
        } else if model.items == nil {
            Section {
                ProgressView().frame(maxWidth: .infinity, minHeight: 80)
            }
            .listRowBackground(Color.clear)
        }
    }

    private func editorView(for target: PackingEditorTarget) -> some View {
        let item: PackingItem? = if case .edit(let item) = target { item } else { nil }
        let category: String? = if case .new(let category) = target { category } else { nil }
        return PackingEditorView(
            item: item,
            category: category,
            categories: model.categories.map(\.name).filter { $0 != PackingModel.uncategorized },
            bags: model.bags,
            bagErrorMessage: model.bagErrorMessage,
            onCreateBag: { try await model.createBag(name: $0) },
            onSave: { try await model.save($0, editing: item) },
            onDelete: { if let item { await model.delete(item) } }
        )
    }

    private func row(for item: PackingItem, tint: Color) -> some View {
        Button {
            editor = .edit(item)
        } label: {
            PackingRow(item: item, tint: tint, bag: model.bags.first { $0.id == item.bagId }) {
                Task { await model.toggle(item) }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
        .listRowBackground(Color.trekCard)
        .listRowInsets(EdgeInsets())
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .alignmentGuide(.listRowSeparatorTrailing) { $0.width }
        .swipeActions(edge: .leading) {
            Button(item.isPacked ? "Unpack" : "Packed", systemImage: item.isPacked ? "arrow.uturn.backward" : "checkmark") {
                Task { await model.toggle(item) }
            }
            .tint(Color.trekSuccess)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", systemImage: "trash", role: .destructive) {
                Task { await model.delete(item) }
            }
            .tint(Color.trekDanger)
        }
    }

    private func packedFoldRow(for category: PackingCategory) -> some View {
        PackingFoldRow(packedCount: category.packedCount, isExpanded: showsPacked.contains(category.id)) {
            withAnimation(.smooth) {
                if showsPacked.contains(category.id) { showsPacked.remove(category.id) } else { showsPacked.insert(category.id) }
            }
        }
        .environment(\.layoutDirection, category.name.isRightToLeft ? .rightToLeft : .leftToRight)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.trekCard)
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .alignmentGuide(.listRowSeparatorTrailing) { $0.width }
    }

    private func quickAddRow(category: String?) -> some View {
        TodoQuickAddRow(placeholder: "Add item") { name in
            let category = category == PackingModel.uncategorized ? nil : category
            try await model.save(PackingInput(name: name, category: category, quantity: 1), editing: nil)
        }
        .environment(\.layoutDirection, (category ?? "").isRightToLeft ? .rightToLeft : .leftToRight)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.trekCard)
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .alignmentGuide(.listRowSeparatorTrailing) { $0.width }
    }

}
