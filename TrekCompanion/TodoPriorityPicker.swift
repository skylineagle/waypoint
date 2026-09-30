import SwiftUI

struct TodoPriorityPicker: View {
    @Binding var selection: TodoPriority

    var body: some View {
        HStack(spacing: 6) {
            ForEach(TodoPriority.allCases) { priority in
                let isSelected = selection == priority
                let tint = priority.color ?? Color.trekText
                Button {
                    selection = priority
                } label: {
                    HStack(spacing: 4) {
                        if priority != .none {
                            Image(systemName: isSelected ? "flag.fill" : "flag")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        Text(priority.label)
                    }
                    .font(.poppins(12.5, .semibold, relativeTo: .footnote))
                    .foregroundStyle(isSelected ? tint : Color.trekTextSecondary)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(isSelected ? tint.opacity(0.1) : Color.trekInput, in: .rect(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(isSelected ? tint : Color.trekBorder))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .animation(.snappy(duration: 0.15), value: selection)
    }
}
