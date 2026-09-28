import SwiftUI

struct ConverterConversion: View {
    let state: ConverterState
    let inputSize: CGFloat
    let resultSize: CGFloat
    var resultCaption = "Costs you"
    var showsCursor = false
    var showsRateInHeader = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                WidgetCaption(text: "Price in \(state.tripCurrency)").foregroundStyle(.secondary)
                Spacer(minLength: 0)
                if showsRateInHeader { ConverterRateLine(state: state) }
                ConverterRefreshButton()
            }
            input
            Spacer(minLength: 4)
            WidgetCaption(text: resultCaption).foregroundStyle(Color.widgetDone)
            Text(state.converted.money(state.displayCurrency))
                .font(.system(size: resultSize, weight: .bold, design: .rounded))
                .foregroundStyle(Color.widgetDone)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            if !showsRateInHeader { ConverterRateLine(state: state) }
        }
    }

    private var input: some View {
        let amount = Text(state.amount.money(state.tripCurrency))
        return Group {
            if showsCursor { amount + Text("|").foregroundStyle(Color.widgetDone) } else { amount }
        }
        .font(.system(size: inputSize, weight: .bold, design: .rounded))
        .lineLimit(1)
        .minimumScaleFactor(0.6)
    }
}
