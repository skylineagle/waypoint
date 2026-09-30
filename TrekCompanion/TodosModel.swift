import Foundation
import Observation

enum TodoFilter: Hashable {
    case all
    case mine
    case list(String)
}

struct TodoSection: Identifiable {
    let title: String
    let items: [TodoItem]
    var isAlert = false

    var id: String { title }
}

@Observable
final class TodosModel {
    let trip: Trip
    private(set) var isAvailable = false
    private(set) var items: [TodoItem]?
    private(set) var errorMessage: String?

    init(trip: Trip) {
        self.trip = trip
    }

    var openCount: Int {
        (items ?? []).count { !$0.isDone }
    }

    var doneCount: Int {
        (items ?? []).count(where: \.isDone)
    }

    var lists: [String] {
        Set((items ?? []).compactMap(\.category)).sorted()
    }

    func sections(for filter: TodoFilter, meID: Int?) -> [TodoSection] {
        let filtered = (items ?? []).filter { item in
            switch filter {
            case .all: true
            case .mine: item.assignedUserId == meID
            case .list(let name): item.category == name
            }
        }
        let open = filtered.filter { !$0.isDone }.sorted(by: Self.isMoreUrgent)
        return [
            TodoSection(title: "Overdue", items: open.filter(\.isOverdue), isAlert: true),
            TodoSection(title: "Upcoming", items: open.filter { $0.dueDate != nil && !$0.isOverdue }),
            TodoSection(title: "No date", items: open.filter { $0.dueDate == nil }),
            TodoSection(title: "Done", items: filtered.filter(\.isDone)),
        ]
        .filter { !$0.items.isEmpty }
    }

    private static func isMoreUrgent(_ first: TodoItem, _ second: TodoItem) -> Bool {
        if first.dueDate != second.dueDate {
            return (first.dueDate ?? "~") < (second.dueDate ?? "~")
        }
        return rank(first.todoPriority) < rank(second.todoPriority)
    }

    private static func rank(_ priority: TodoPriority) -> Int {
        priority == .none ? 4 : priority.rawValue
    }

    func load() async {
        guard let client = TrekClient.current else { return }
        isAvailable = await client.hasTodos()
        guard isAvailable else { return }
        do {
            items = try await client.todos(tripID: trip.id)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(_ input: TodoInput, editing item: TodoItem?) async throws {
        guard let client = TrekClient.current else { return }
        let saved = if let item {
            try await client.updateTodo(id: item.id, input, tripID: trip.id)
        } else {
            try await client.addTodo(input, tripID: trip.id)
        }
        var updated = items ?? []
        if let index = updated.firstIndex(where: { $0.id == saved.id }) {
            updated[index] = saved
        } else {
            updated.append(saved)
        }
        items = updated
    }

    func toggle(_ item: TodoItem) async {
        guard let client = TrekClient.current, let index = items?.firstIndex(of: item) else { return }
        let isDone = !item.isDone
        items?[index].checked = isDone ? 1 : 0
        do {
            try await client.setTodo(id: item.id, checked: isDone, tripID: trip.id)
        } catch {
            errorMessage = error.localizedDescription
            await load()
        }
    }

    func delete(_ item: TodoItem) async {
        guard let client = TrekClient.current else { return }
        items?.removeAll { $0.id == item.id }
        do {
            try await client.deleteTodo(id: item.id, tripID: trip.id)
        } catch {
            errorMessage = error.localizedDescription
            await load()
        }
    }
}
