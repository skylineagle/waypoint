import SwiftUI

struct ShortcutInstruction {
    let symbol: String
    let text: LocalizedStringKey
}

struct ShortcutInstructionRow: View {
    let instruction: ShortcutInstruction

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: instruction.symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.trekAccentText)
                .frame(width: 34, height: 34)
                .background(Color.trekAccent, in: .rect(cornerRadius: 10))
                .accessibilityHidden(true)
            Text(instruction.text)
                .font(.poppins(14, relativeTo: .subheadline))
                .foregroundStyle(Color.trekTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
    }
}
