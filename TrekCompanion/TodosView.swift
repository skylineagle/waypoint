import SwiftUI

enum TodoEditorTarget: Identifiable {
    case new
    case edit(TodoItem)

    var id: Int {
        switch self {
        case .new: -1
        case .edit(let item): item.id
        }
    }

    var item: TodoItem? {
        if case .edit(let item) = self { item } else { nil }
    }
}

struct TodosView: View {
    let model: TodosModel
    let members: [TripMember]
    let meID: Int?
    @State private var filter = TodoFilter.all
    @State private var editor: TodoEditorTarget?

    private var sections: [TodoSection] {
        model.sections(for: filter, meID: meID)
    }

    var body: some View {
        List {
            Section {
                filterChips.plainListRow()
            }
            status
            ForEach(sections) { section in
                Section {
                    ForEach(section.items) { item in
                        row(for: item)
                    }
                    if section.id == sections.last(where: { $0.title != "Done" })?.id {
                        quickAddRow
                    }
                } header: {
                    sectionHeader(section)
                }
            }
            if model.items != nil, !sections.contains(where: { $0.title != "Done" }) {
                Section { quickAddRow }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(10)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .contentMargins(.top, 0, for: .scrollContent)
        .contentMargins(.bottom, 72, for: .scrollContent)
        .overlay(alignment: .bottomTrailing) {
            ListsAddButton(label: "New to-do") { editor = .new }
        }
        .refreshable { await model.load() }
        .animation(.smooth, value: model.items)
        .sheet(item: $editor) { target in
            TodoEditorView(
                item: target.item,
                lists: model.lists,
                members: members,
                meID: meID,
                onSave: { try await model.save($0, editing: target.item) },
                onDelete: { if let item = target.item { await model.delete(item) } }
            )
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                FilterChip(title: "All", isSelected: filter == .all) { filter = .all }
                if meID != nil {
                    FilterChip(title: "Mine", isSelected: filter == .mine) { filter = filter == .mine ? .all : .mine }
                }
                ForEach(model.lists, id: \.self) { name in
                    FilterChip(title: name, isSelected: filter == .list(name)) {
                        filter = filter == .list(name) ? .all : .list(name)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var status: some View {
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

    private func row(for item: TodoItem) -> some View {
        Button {
            editor = .edit(item)
        } label: {
            TodoRow(item: item, assigneeName: assigneeName(of: item)) {
                Task { await model.toggle(item) }
            }
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.trekCard)
        .swipeActions(edge: .leading) {
            Button(item.isDone ? "Undo" : "Done", systemImage: item.isDone ? "arrow.uturn.backward" : "checkmark") {
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

    private var quickAddRow: some View {
        TodoQuickAddRow { name in
            try? await model.save(quickAddInput(named: name), editing: nil)
        }
        .listRowBackground(Color.trekCard)
    }

    private func quickAddInput(named name: String) -> TodoInput {
        var input = TodoInput(name: name, priority: 0)
        switch filter {
        case .all: break
        case .mine: input.assignedUserId = meID
        case .list(let list): input.category = list
        }
        return input
    }

    private func sectionHeader(_ section: TodoSection) -> some View {
        HStack {
            Text(section.title)
            Spacer()
            Text("\(section.items.count)")
        }
        .font(.poppins(11.5, .semibold, relativeTo: .caption))
        .foregroundStyle(section.isAlert ? Color.trekDanger : Color.trekMuted)
    }

    private func assigneeName(of item: TodoItem) -> String? {
        guard let id = item.assignedUserId else { return nil }
        if id == meID { return "You" }
        return members.first { $0.id == id }?.username
    }
}
