import SwiftUI

extension View {
    func trekCard() -> some View {
        background(Color.trekCard, in: .rect(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.trekBorder))
    }
}
