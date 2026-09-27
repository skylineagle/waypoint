import SwiftUI

enum ServerStatus {
    case idle, checking, found, notFound
}

struct ServerStatusLabel: View {
    let status: ServerStatus

    var body: some View {
        Group {
            switch status {
            case .idle:
                Text(" ")
            case .checking:
                HStack(spacing: 6) {
                    ProgressView().controlSize(.mini)
                    Text("Looking for TREK…")
                }
                .foregroundStyle(Color.trekMuted)
            case .found:
                Label("TREK found", systemImage: "checkmark.circle")
                    .foregroundStyle(Color.trekSuccess)
            case .notFound:
                Label("No TREK server at this address", systemImage: "exclamationmark.circle")
                    .foregroundStyle(Color.trekDanger)
            }
        }
        .font(.poppins(13, relativeTo: .footnote))
        .padding(.horizontal, 2)
        .animation(.easeOut(duration: 0.15), value: status)
    }
}
