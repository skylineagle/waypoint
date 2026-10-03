import SwiftUI

struct PackingRow: View {
    let item: PackingItem
    let tint: Color
    let bag: PackingBag?
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            TodoCheckbox(isDone: item.isPacked, tint: tint, onToggle: onToggle)
            Text(item.name)
                .font(.poppins(15, item.isPacked ? .regular : .medium))
                .foregroundStyle(item.isPacked ? Color.trekFaint : Color.trekText)
                .strikethrough(item.isPacked, color: Color.trekFaint)
                .lineLimit(2)
            if let quantity = item.quantity, quantity > 1 {
                Text("×\(quantity)")
                    .font(.poppins(12, .semibold, relativeTo: .caption))
                    .foregroundStyle(Color.trekMuted)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.trekFaint.opacity(0.18), in: .capsule)
                    .environment(\.layoutDirection, .leftToRight)
            }
            Spacer(minLength: 0)
            if let bag {
                PackingBagChip(bag: bag)
                    .frame(maxWidth: 140, alignment: .trailing)
            } else if item.bagId != nil {
                Label("Bag unavailable", systemImage: "bag")
                    .font(.poppins(11, relativeTo: .caption))
                    .foregroundStyle(Color.trekMuted)
            }
        }
        .environment(\.layoutDirection, item.name.isRightToLeft ? .rightToLeft : .leftToRight)
        .contentShape(.rect)
    }
}
