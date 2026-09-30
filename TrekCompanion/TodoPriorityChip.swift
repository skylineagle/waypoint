import SwiftUI

struct TodoPriorityChip: View {
    let priority: TodoPriority
    let color: Color

    var body: some View {
        Label(priority.label, systemImage: "flag.fill")
            .labelStyle(.titleAndIcon)
            .font(.poppins(10.5, .semibold, relativeTo: .caption2))
            .imageScale(.small)
            .foregroundStyle(color)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(color.opacity(0.12), in: .capsule)
    }
}
