import SwiftUI

struct FieldLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.poppins(13, .semibold, relativeTo: .footnote))
            .foregroundStyle(Color.trekTextSecondary)
            .padding(.horizontal, 2)
    }
}
