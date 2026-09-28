import AppIntents
import SwiftUI

struct ConverterRefreshButton: View {
    var body: some View {
        Button(intent: RefreshRatesIntent()) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 26, height: 22)
        }
        .buttonStyle(.plain)
    }
}
