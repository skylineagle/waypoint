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
    @State private var headerHeight: CGFloat = 70
    @State private var isConfirmingDelete = false
    @State private var isConfirmingDiscard = false
    private let original: Fields

    private struct Fields: Equatable {
        var name: String
        var description: String
        var list: String?
        var dueDate: Date?
        var assigneeID: Int?
        var priority: TodoPriority
    }

    private var hasChanges: Bool {
        original != Fields(name: name, description: description, list: list, dueDate: dueDate, assigneeID: assigneeID, priority: priority)
    }

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
        let fields = Fields(
            name: item?.name ?? "",
            description: item?.description ?? "",
            list: item?.category,
            dueDate: ExpenseDate.date(from: item?.dueDate),
            assigneeID: item?.assignedUserId,
            priority: item?.todoPriority ?? .none
        )
        original = fields
        _name = State(initialValue: fields.name)
        _description = State(initialValue: fields.description)
        _list = State(initialValue: fields.list)
        _dueDate = State(initialValue: fields.dueDate)
        _assigneeID = State(initialValue: fields.assigneeID)
        _priority = State(initialValue: fields.priority)
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
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 10)
                .fixedSize(horizontal: false, vertical: true)
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { headerHeight = $0 }
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
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
                    Button(item == nil ? "Add to-do" : "Save to-do", action: save)
                        .buttonStyle(TrekButtonStyle())
                        .disabled(!canSave)
                        .padding(.top, 8)
                    if item != nil {
                        Button("Delete to-do", role: .destructive) { isConfirmingDelete = true }
                        .font(.poppins(15, .semibold))
                        .foregroundStyle(Color.trekDanger)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { contentHeight = $0 }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.trekBackground)
        .presentationDetents([.height(contentHeight + headerHeight)])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(hasChanges)
        .confirmationDialog("Delete this to-do?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Delete To-Do", role: .destructive) {
                Task {
                    await onDelete()
                    dismiss()
                }
            }
        } message: {
            Text("It's removed from the trip for everyone.")
        }
        .confirmationDialog("Discard your changes?", isPresented: $isConfirmingDiscard, titleVisibility: .visible) {
            Button("Discard Changes", role: .destructive) { dismiss() }
            Button("Keep Editing", role: .cancel) {}
        }
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
            SheetHeaderButton(label: "Cancel", symbol: "xmark", isFilled: false) {
                if hasChanges { isConfirmingDiscard = true } else { dismiss() }
            }
            Spacer()
            Text(item == nil ? "New to-do" : "Edit to-do")
                .font(.poppins(15, .semibold, relativeTo: .headline))
                .foregroundStyle(Color.trekText)
            Spacer()
            SheetHeaderButton(label: "Cancel", symbol: "xmark", isFilled: false) {}
                .hidden()
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
