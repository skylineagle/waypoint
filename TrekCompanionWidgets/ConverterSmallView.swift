import AppIntents
import SwiftUI

struct ConverterSmallView: View {
    let state: ConverterState

    var body: some View {
        VStack(spacing: 6) {
            ConverterConversion(state: state, inputSize: 18, resultSize: 30)
            HStack(spacing: 6) {
                stepButton("minus", direction: -1, isPrimary: false)
                stepButton("plus", direction: 1, isPrimary: true)
            }
        }
    }

    private func stepButton(_ symbol: String, direction: Int, isPrimary: Bool) -> some View {
        Button(intent: ConverterStepIntent(direction: direction)) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: 30)
                .foregroundStyle(isPrimary ? Color.black : Color.primary)
                .background(isPrimary ? Color.widgetDone : Color.primary.opacity(0.12), in: .capsule)
        }
        .buttonStyle(.plain)
    }
}
