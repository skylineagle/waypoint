import AppIntents
import SwiftUI

struct ConverterKeypad: View {
    let keyHeight: CGFloat

    private static let rows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], [".", "0", "⌫"]]

    var body: some View {
        Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            ForEach(Self.rows, id: \.self) { row in
                GridRow {
                    ForEach(row, id: \.self, content: keyButton)
                }
            }
        }
    }

    private func keyButton(_ key: String) -> some View {
        Button(intent: ConverterKeyIntent(key: key)) {
            Text(key)
                .font(.system(size: keyHeight * 0.5, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: keyHeight)
                .foregroundStyle(.primary)
                .background(Color.primary.opacity(key.first?.isNumber == true ? 0.12 : 0.2), in: .rect(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}
