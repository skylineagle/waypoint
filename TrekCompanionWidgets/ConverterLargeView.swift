import SwiftUI

struct ConverterLargeView: View {
    let state: ConverterState

    var body: some View {
        VStack(spacing: 12) {
            ConverterConversion(
                state: state,
                inputSize: 22,
                resultSize: 44,
                resultCaption: "Costs you in \(state.displayCurrency)",
                showsCursor: true,
                showsRateInHeader: true
            )
            ConverterKeypad(keyHeight: 42)
        }
    }
}
