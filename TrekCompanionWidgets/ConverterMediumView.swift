import SwiftUI

struct ConverterMediumView: View {
    let state: ConverterState

    var body: some View {
        HStack(spacing: 12) {
            ConverterConversion(state: state, inputSize: 20, resultSize: 28, showsCursor: true)
            ConverterKeypad(keyHeight: 28).frame(width: 150)
        }
    }
}
