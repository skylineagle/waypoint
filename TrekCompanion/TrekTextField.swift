import SwiftUI

struct TrekTextField: View {
    let symbol: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    var focusOnAppear = false
    var accessibilityLabel: String?
    @FocusState private var isFocused: Bool
    @State private var isRevealed = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 15))
                .foregroundStyle(Color.trekFaint)
                .frame(width: 20)
                .accessibilityHidden(true)

            Group {
                if isSecure && !isRevealed {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.poppins(15))
            .foregroundStyle(Color.trekText)
            .focused($isFocused)
            .accessibilityLabel(accessibilityLabel ?? placeholder)

            if isSecure {
                Button(isRevealed ? "Hide password" : "Show password", systemImage: isRevealed ? "eye.slash" : "eye") {
                    isRevealed.toggle()
                }
                .labelStyle(.iconOnly)
                .font(.system(size: 15))
                .foregroundStyle(Color.trekFaint)
            }
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 50)
        .background(Color.trekInput, in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isFocused ? Color.trekAccent : Color.trekBorder, lineWidth: 1)
        }
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.trekAccent.opacity(isFocused ? 0.08 : 0))
                .padding(-3)
        }
        .contentShape(.rect)
        .onTapGesture { isFocused = true }
        .onAppear { isFocused = focusOnAppear }
        .animation(.easeOut(duration: 0.15), value: isFocused)
    }
}
