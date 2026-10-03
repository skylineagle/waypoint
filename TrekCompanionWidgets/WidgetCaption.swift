import SwiftUI

struct WidgetCaption: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .bold))
            .tracking(0.8)
            .lineLimit(1)
    }
}
