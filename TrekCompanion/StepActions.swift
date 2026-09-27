import SwiftUI

extension View {
    func stepActions(@ViewBuilder _ actions: () -> some View) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10, content: actions)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.trekBackground)
            }
    }
}
