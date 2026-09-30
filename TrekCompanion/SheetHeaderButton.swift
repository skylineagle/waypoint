import SwiftUI

struct SheetHeaderButton: View {
    let label: String
    let symbol: String
    let isFilled: Bool
    let action: () -> Void

    var body: some View {
        let button = Button(label, systemImage: symbol, action: action)
            .labelStyle(.iconOnly)
            .font(.system(size: 15, weight: .bold))
            .buttonBorderShape(.circle)
            .controlSize(.large)
        if isFilled {
            button.buttonStyle(.glassProminent).tint(Color.trekAccent).foregroundStyle(Color.trekAccentText)
        } else {
            button.buttonStyle(.glass).foregroundStyle(Color.trekText)
        }
    }
}
