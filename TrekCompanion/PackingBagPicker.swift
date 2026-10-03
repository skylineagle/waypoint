import SwiftUI

struct PackingBagPicker: View {
    let bags: [PackingBag]
    let errorMessage: String?
    @Binding var selectedId: Int?
    let onNewBag: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bag")
                .font(.poppins(15, .semibold))
                .foregroundStyle(Color.trekText)
            Text("Choose the bag this item belongs to.")
                .font(.poppins(12, relativeTo: .footnote))
                .foregroundStyle(Color.trekMuted)
            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle")
                    .font(.poppins(13, relativeTo: .footnote))
                    .foregroundStyle(Color.trekMuted)
            } else {
                VStack(spacing: 0) {
                    option(name: "No bag", id: nil)
                    ForEach(bags) { bag in
                        Divider().overlay(Color.trekDivider)
                        option(name: bag.name, id: bag.id)
                    }
                    Divider().overlay(Color.trekDivider)
                    Button(action: onNewBag) {
                        Label("New bag", systemImage: "plus")
                            .font(.poppins(14, .medium))
                            .foregroundStyle(Color.trekTextSecondary)
                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 14)
                }
                .trekCard()
            }
        }
        .padding(.top, 6)
    }

    private func option(name: String, id: Int?) -> some View {
        Button {
            selectedId = id
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "bag")
                    .foregroundStyle(Color.trekFaint)
                    .accessibilityHidden(true)
                Text(name)
                    .foregroundStyle(Color.trekText)
                    .multilineTextAlignment(.leading)
                    .environment(\.layoutDirection, name.isRightToLeft ? .rightToLeft : .leftToRight)
                Spacer(minLength: 8)
                if selectedId == id {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.trekSuccess)
                        .accessibilityHidden(true)
                }
            }
            .font(.poppins(14))
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 50)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(name)
        .accessibilityAddTraits(selectedId == id ? [.isSelected] : [])
    }
}
