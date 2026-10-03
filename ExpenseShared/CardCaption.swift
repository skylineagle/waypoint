import SwiftUI

struct CardCaption: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.poppins(10, .bold, relativeTo: .caption2))
            .tracking(0.9)
            .foregroundStyle(Color.trekFaint)
            .fixedSize(horizontal: false, vertical: true)
    }
}
