import SwiftUI

struct TodayHeader: View {
    let eyebrow: String
    let title: String
    var isCompact = false
    let weather: DayWeather?
    let weatherURL: URL?
    @Binding var isMapShown: Bool
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .subheadline) private var buttonSize = 38

    private var layout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8)) : AnyLayout(HStackLayout(alignment: .top))
    }

    var body: some View {
        layout {
            VStack(alignment: .leading, spacing: 1) {
                CardCaption(text: eyebrow)
                Text(title)
                    .font(.poppins(isCompact ? 18 : 26, .bold, relativeTo: isCompact ? .headline : .largeTitle))
                    .tracking(-0.5)
                    .foregroundStyle(Color.trekText)
                    .accessibilityAddTraits(.isHeader)
                    .lineLimit(isCompact ? 1 : 3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            HStack(spacing: 8) {
                if let weather {
                    Button {
                        if let weatherURL { openURL(weatherURL) }
                    } label: {
                        Label("\(Int(weather.temp.rounded()))°", systemImage: weather.symbol)
                            .font(.poppins(13, .semibold, relativeTo: .subheadline))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.trekText)
                            .padding(.horizontal, 10)
                            .frame(height: buttonSize)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive())
                    .accessibilityHint("Opens the weather for your next stop")
                }
                Button(isMapShown ? "Show list" : "Show map", systemImage: isMapShown ? "list.bullet" : "map") {
                    withAnimation(.smooth(duration: 0.35)) { isMapShown.toggle() }
                }
                .labelStyle(.iconOnly)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isMapShown ? Color.trekAccentText : Color.trekText)
                .frame(width: buttonSize, height: buttonSize)
                .glassEffect(isMapShown ? .regular.tint(.trekAccent).interactive() : .regular.interactive(), in: .circle)
                .contentTransition(.symbolEffect(.replace))
            }
        }
        .padding(.top, 4)
    }
}
