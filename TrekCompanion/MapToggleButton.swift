import SwiftUI

struct MapToggleButton: View {
    @Binding var isMapShown: Bool
    @ScaledMetric(relativeTo: .subheadline) private var size = 38

    var body: some View {
        Button(isMapShown ? "Hide map" : "Show map", systemImage: isMapShown ? "map.fill" : "map") {
            isMapShown.toggle()
        }
        .labelStyle(.iconOnly)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(isMapShown ? Color.trekAccentText : Color.trekText)
        .frame(width: size, height: size)
        .glassEffect(isMapShown ? .regular.tint(.trekAccent).interactive() : .regular.interactive(), in: .circle)
        .contentTransition(.symbolEffect(.replace))
    }
}
