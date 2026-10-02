import SwiftUI

struct MapToggleButton: View {
    @Binding var isMapShown: Bool

    var body: some View {
        Button(isMapShown ? "Hide map" : "Show map", systemImage: isMapShown ? "map.fill" : "map") {
            isMapShown.toggle()
        }
        .labelStyle(.iconOnly)
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(isMapShown ? Color.trekAccentText : Color.trekText)
        .frame(width: 38, height: 38)
        .glassEffect(isMapShown ? .regular.tint(.trekAccent).interactive() : .regular.interactive(), in: .circle)
        .contentTransition(.symbolEffect(.replace))
    }
}
