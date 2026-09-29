import SwiftUI

struct ConverterSheet: View {
    let converter: CurrencyConverter
    let amount: Double

    var body: some View {
        CurrencyConverterCard(converter: converter, amount: amount, showsSlider: true)
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.trekBackground)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
    }
}
