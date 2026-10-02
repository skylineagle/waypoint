import SwiftUI

struct TodayHeader: View {
    let eyebrow: String
    let title: String
    let weather: DayWeather?
    let weatherURL: URL?
    @Binding var isMapShown: Bool
    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 1) {
                CardCaption(text: eyebrow)
                Text(title)
                    .font(.poppins(26, .bold, relativeTo: .largeTitle))
                    .tracking(-0.5)
                    .foregroundStyle(Color.trekText)
                    .accessibilityAddTraits(.isHeader)
                    .lineLimit(2)
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
                            .frame(height: 38)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive())
                    .accessibilityHint("Opens the weather for your next stop")
                }
                Button(isMapShown ? "Show list" : "Show map", systemImage: isMapShown ? "list.bullet" : "map") {
                    withAnimation(.smooth(duration: 0.35)) { isMapShown.toggle() }
                }
                .labelStyle(.iconOnly)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isMapShown ? Color.trekAccentText : Color.trekText)
                .frame(width: 38, height: 38)
                .glassEffect(isMapShown ? .regular.tint(.trekAccent).interactive() : .regular.interactive(), in: .circle)
                .contentTransition(.symbolEffect(.replace))
            }
        }
        .padding(.top, 4)
    }
}
