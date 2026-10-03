import SwiftUI

struct LabelVisibility: LabelStyle {
    let isIconOnly: Bool

    func makeBody(configuration: Configuration) -> some View {
        if isIconOnly {
            configuration.icon
        } else {
            Label(configuration)
        }
    }
}
