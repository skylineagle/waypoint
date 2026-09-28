import SwiftUI

struct ConverterRateLine: View {
    let state: ConverterState

    var body: some View {
        Text("\(1.0.money(state.tripCurrency)) = \(state.rate.money(state.displayCurrency, fractionDigits: 2...4))")
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}
