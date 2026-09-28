import SwiftUI

struct CurrencyConverterCard: View {
    let converter: CurrencyConverter
    let showsSlider: Bool
    @State private var amount: Double
    @State private var isFromTrip = true
    @FocusState private var isEditing: Bool

    init(converter: CurrencyConverter, amount: Double = 1000, showsSlider: Bool = false) {
        self.converter = converter
        self.showsSlider = showsSlider
        _amount = State(initialValue: amount)
    }

    private var from: String { isFromTrip ? converter.tripCurrency : converter.displayCurrency }
    private var to: String { isFromTrip ? converter.displayCurrency : converter.tripCurrency }

    private var sliderPosition: Binding<Double> {
        Binding(
            get: { log10(max(amount, 1)) },
            set: { amount = Double(String(format: "%.1e", pow(10, $0))) ?? amount }
        )
    }

    private var rateLine: String {
        let forward = converter.convert(1, from: converter.tripCurrency, to: converter.displayCurrency)
        let backward = converter.convert(1, from: converter.displayCurrency, to: converter.tripCurrency)
        return "\(1.0.money(converter.tripCurrency)) = \(forward.money(converter.displayCurrency, fractionDigits: 2...4)) · \(1.0.money(converter.displayCurrency)) = \(backward.money(converter.tripCurrency))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CardCaption(text: "Currency")
            HStack(spacing: 8) {
                currencyBox(label: "\(from) · \(isFromTrip ? "Trip" : "Yours")") {
                    TextField("Amount", value: $amount, format: .number.precision(.fractionLength(0...2)))
                        .keyboardType(.decimalPad)
                        .focused($isEditing)
                }
                Button("Swap currencies", systemImage: "arrow.left.arrow.right") {
                    amount = converter.convert(amount, from: from, to: to)
                    isFromTrip.toggle()
                }
                .labelStyle(.iconOnly)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.trekText)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                currencyBox(label: "\(to) · \(isFromTrip ? "Yours" : "Trip")") {
                    Text(converter.convert(amount, from: from, to: to).money(to))
                        .lineLimit(1)
                        .contentTransition(.numericText())
                }
            }
            if showsSlider {
                Slider(value: sliderPosition, in: 0...7)
            }
            Text(rateLine)
                .font(.poppins(11, relativeTo: .caption2))
                .foregroundStyle(Color.trekMuted)
        }
        .padding(13)
        .background(Color.trekCard, in: .rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.trekBorder))
        .toolbar {
            if isEditing {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isEditing = false }
                }
            }
        }
    }

    private func currencyBox(label: String, @ViewBuilder value: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.poppins(11, .semibold, relativeTo: .caption2))
                .foregroundStyle(Color.trekMuted)
            value()
                .font(.poppins(18, .bold, relativeTo: .title3))
                .foregroundStyle(Color.trekText)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.trekBackground, in: .rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.trekBorder))
    }
}
