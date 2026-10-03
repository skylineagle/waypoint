import QuickLook
import SwiftUI

struct BookingButton<Content: View>: View {
    let reservation: Reservation
    @ViewBuilder let content: (BookingIcon) -> Content
    @Environment(TodayModel.self) private var model
    @Environment(\.openURL) private var openURL
    @State private var previewURL: URL?
    @State private var previewURLs: [URL] = []
    @State private var isOpening = false

    private var files: [TripFile] { model.files(for: reservation) }

    var body: some View {
        Button(action: open) {
            content(BookingIcon(hasFiles: !files.isEmpty, isOpening: isOpening))
        }
        .buttonStyle(.plain)
        .disabled(isOpening)
        .accessibilityHint(files.isEmpty ? "Opens this booking in TREK" : "Opens the booking documents")
        .quickLookPreview($previewURL, in: previewURLs)
    }

    private func open() {
        guard !files.isEmpty, let client = TrekClient.current else {
            if let url = reservation.webURL { openURL(url) }
            return
        }
        isOpening = true
        Task {
            defer { isOpening = false }
            var urls: [URL] = []
            for file in files {
                if let url = try? await client.localCopy(of: file) { urls.append(url) }
            }
            guard let first = urls.first else {
                if let url = reservation.webURL { openURL(url) }
                return
            }
            previewURLs = urls
            previewURL = first
        }
    }
}
