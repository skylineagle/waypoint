import SwiftUI

struct TodoCheckbox: View {
    let isDone: Bool
    var tint = Color.trekSuccess
    let onToggle: () -> Void
    @State private var isCompleting = false

    private var isChecked: Bool { isDone || isCompleting }

    var body: some View {
        Button(action: toggle) {
            ZStack {
                Circle().strokeBorder(Color.trekFaint, lineWidth: 1.6)
                if isChecked {
                    Circle().fill(tint)
                        .transition(.scale(scale: 0.2).combined(with: .opacity))
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .transition(.symbolEffect(.drawOn))
                }
            }
            .frame(width: 22, height: 22)
            .contentShape(.rect.inset(by: -10))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isChecked ? "Mark as not done" : "Mark as done")
        .sensoryFeedback(.success, trigger: isChecked) { _, isChecked in isChecked }
        .animation(.bouncy, value: isChecked)
    }

    private func toggle() {
        guard !isDone else { return onToggle() }
        isCompleting = true
        Task {
            try? await Task.sleep(for: .seconds(0.9))
            onToggle()
            isCompleting = false
        }
    }
}
