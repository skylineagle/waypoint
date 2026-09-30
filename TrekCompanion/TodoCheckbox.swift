import SwiftUI

struct TodoCheckbox: View {
    let item: TodoItem
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            ZStack {
                if item.isDone {
                    Circle().fill(Color.trekSuccess)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Circle().strokeBorder(Color.trekFaint, lineWidth: 1.6)
                }
            }
            .frame(width: 22, height: 22)
            .contentShape(.rect.inset(by: -10))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.isDone ? "Mark as not done" : "Mark as done")
        .sensoryFeedback(.success, trigger: item.isDone) { _, isDone in isDone }
        .animation(.snappy, value: item.isDone)
    }
}
