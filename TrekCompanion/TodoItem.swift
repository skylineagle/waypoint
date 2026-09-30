import SwiftUI

struct TodoItem: Decodable, Identifiable, Hashable {
    let id: Int
    var name: String
    var checked: Int
    var category: String?
    var dueDate: String?
    var description: String?
    var assignedUserId: Int?
    var priority: Int?

    var isDone: Bool { checked != 0 }

    var isOverdue: Bool {
        guard !isDone, let dueDate else { return false }
        return dueDate < ExpenseDate.today
    }

    var todoPriority: TodoPriority {
        TodoPriority(rawValue: priority ?? 0) ?? .none
    }
}

enum TodoPriority: Int, CaseIterable, Identifiable {
    case none, p1, p2, p3

    var id: Int { rawValue }

    var label: String {
        self == .none ? "None" : "P\(rawValue)"
    }

    var color: Color? {
        switch self {
        case .none: nil
        case .p1: Color(hex: 0xEF4444)
        case .p2: Color(hex: 0xF59E0B)
        case .p3: Color(hex: 0x3B82F6)
        }
    }
}

struct TodoInput: Encodable {
    var name: String
    var description: String?
    var dueDate: String?
    var category: String?
    var assignedUserId: Int?
    var priority: Int

    private enum CodingKeys: CodingKey {
        case name, description, dueDate, category, assignedUserId, priority
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(category, forKey: .category)
        try container.encode(assignedUserId, forKey: .assignedUserId)
        try container.encode(priority, forKey: .priority)
    }
}
