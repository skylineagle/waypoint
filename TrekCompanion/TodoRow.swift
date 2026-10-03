import SwiftUI

struct TodoRow: View {
    let item: TodoItem
    let assigneeName: String?
    let onToggle: () -> Void

    private var dueLabel: String? {
        ExpenseDate.date(from: item.dueDate)?.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }

    private var details: String? {
        let parts = [dueLabel, assigneeName].compactMap(\.self)
        return parts.isEmpty ? item.description : parts.joined(separator: " · ")
    }

    private var priorityColor: Color? {
        item.isDone ? nil : item.todoPriority.color
    }

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            TodoCheckbox(isDone: item.isDone, onToggle: onToggle)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.poppins(14, item.isDone ? .regular : .semibold))
                    .foregroundStyle(item.isDone ? Color.trekFaint : Color.trekText)
                    .strikethrough(item.isDone, color: Color.trekFaint)
                    .lineLimit(2)
                    .naturalDirection(of: item.name)
                if priorityColor != nil || details?.isEmpty == false {
                    HStack(spacing: 6) {
                        if let priorityColor {
                            TodoPriorityChip(priority: item.todoPriority, color: priorityColor)
                        }
                        if let details, !details.isEmpty {
                            Text(details)
                                .font(.poppins(11.5, relativeTo: .caption))
                                .foregroundStyle(item.isOverdue ? Color.trekDanger : Color.trekMuted)
                                .lineLimit(1)
                                .naturalDirection(of: details)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 3)
        .contentShape(.rect)
    }
}
