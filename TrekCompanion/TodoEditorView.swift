import SwiftUI

struct TodoEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let item: TodoItem?
    let lists: [String]
    let members: [TripMember]
    let meID: Int?
    let onSave: (TodoInput) async throws -> Void
    let onDelete: () async -> Void

    @State private var name: String
    @State private var description: String
    @State private var list: String?
    @State private var dueDate: Date?
    @State private var assigneeID: Int?
    @State private var priority: TodoPriority
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var isNamingList = false
    @State private var newListName = ""
    @State private var contentHeight: CGFloat = 520

    init(
        item: TodoItem?,
        lists: [String],
        members: [TripMember],
        meID: Int?,
        onSave: @escaping (TodoInput) async throws -> Void,
        onDelete: @escaping () async -> Void
    ) {
        self.item = item
        self.lists = lists
        self.members = members
        self.meID = meID
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: item?.name ?? "")
        _description = State(initialValue: item?.description ?? "")
        _list = State(initialValue: item?.category)
        _dueDate = State(initialValue: ExpenseDate.date(from: item?.dueDate))
        _assigneeID = State(initialValue: item?.assignedUserId)
        _priority = State(initialValue: item?.todoPriority ?? .none)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !isSaving
    }

    private var assigneeName: String {
        guard let assigneeID else { return "Nobody" }
        if assigneeID == meID { return "You" }
        return members.first { $0.id == assigneeID }?.username ?? "Nobody"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            TrekTextField(symbol: "pencil", placeholder: "What needs doing?", text: $name, focusOnAppear: item == nil, accessibilityLabel: "Name")
            TrekTextField(symbol: "text.alignleft", placeholder: "Description", text: $description, accessibilityLabel: "Description", axis: .vertical)
                .lineLimit(1...4)
            CardCaption(text: "Details").padding(.top, 6)
            details
            CardCaption(text: "Priority").padding(.top, 6)
            TodoPriorityPicker(selection: $priority)
            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle")
                    .font(.poppins(13, relativeTo: .footnote))
                    .foregroundStyle(Color.trekDanger)
            }
            if item != nil {
                Button("Delete to-do", role: .destructive) {
                    Task {
                        await onDelete()
                        dismiss()
                    }
                }
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
        .alert("New list", isPresented: $isNamingList) {
            TextField("List name", text: $newListName)
            Button("Cancel", role: .cancel) {}
            Button("Add") {
                let trimmed = newListName.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty { list = trimmed }
            }
        }
    }

    private var header: some View {
        HStack {
            SheetHeaderButton(label: "Cancel", symbol: "xmark", isFilled: false) { dismiss() }
            Spacer()
            Text(item == nil ? "New to-do" : "Edit to-do")
                .font(.poppins(15, .semibold, relativeTo: .headline))
                .foregroundStyle(Color.trekText)
            Spacer()
            SheetHeaderButton(label: "Save", symbol: "checkmark", isFilled: true, action: save)
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.35)
        }
        .padding(.bottom, 4)
    }

    private var details: some View {
        VStack(spacing: 0) {
            detailRow("List", symbol: "list.bullet") {
                Menu {
                    Button("No list") { list = nil }
                    ForEach(Array(Set(lists + [list].compactMap(\.self))).sorted(), id: \.self) { name in
                        Button(name) { list = name }
                    }
                    Divider()
                    Button("New list…", systemImage: "plus") {
                        newListName = ""
                        isNamingList = true
                    }
                } label: {
                    menuLabel(list ?? "No list")
                }
            }
            Divider().overlay(Color.trekDivider)
            detailRow("Due date", symbol: "calendar") {
                if let dueDate {
                    HStack(spacing: 4) {
                        DatePicker("Due date", selection: Binding(get: { dueDate }, set: { self.dueDate = $0 }), displayedComponents: .date)
                            .labelsHidden()
                        Button("Remove due date", systemImage: "xmark.circle.fill") { self.dueDate = nil }
                            .labelStyle(.iconOnly)
                            .foregroundStyle(Color.trekFaint)
                    }
                } else {
                    Button("Add") { dueDate = ExpenseDate.now }
                        .font(.poppins(14, .semibold))
                        .foregroundStyle(Color.trekText)
                }
            }
            if !members.isEmpty {
                Divider().overlay(Color.trekDivider)
                detailRow("Assignee", symbol: "person") {
                    Menu {
                        Button("Nobody") { assigneeID = nil }
                        ForEach(members) { member in
                            Button(member.id == meID ? "You" : member.username) { assigneeID = member.id }
                        }
                    } label: {
                        menuLabel(assigneeName)
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .trekCard()
    }

    private func detailRow(_ title: String, symbol: String, @ViewBuilder trailing: () -> some View) -> some View {
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
            trailing()
        }
        .frame(minHeight: 50)
    }

    private func menuLabel(_ text: String) -> some View {
        HStack(spacing: 4) {
            Text(text).lineLimit(1)
            Image(systemName: "chevron.up.chevron.down").font(.system(size: 10, weight: .semibold))
        }
        .font(.poppins(14))
        .foregroundStyle(Color.trekMuted)
    }

    private func save() {
        guard canSave else { return }
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let input = TodoInput(
            name: name.trimmingCharacters(in: .whitespaces),
            description: trimmedDescription.isEmpty ? nil : trimmedDescription,
            dueDate: dueDate.map { ExpenseDate.format.format($0) },
            category: list,
            assignedUserId: assigneeID,
            priority: priority.rawValue
        )
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
