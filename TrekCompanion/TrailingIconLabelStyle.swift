import SwiftUI

struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.title
            configuration.icon
        }
    }
}
