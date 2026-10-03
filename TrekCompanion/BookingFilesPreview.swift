import QuickLook
import SwiftUI

struct BookingFilesPreview: ViewModifier {
    let model: TodayModel
    @Environment(AppModel.self) private var app
    @State private var previewURL: URL?
    @State private var previewURLs: [URL] = []

    func body(content: Content) -> some View {
        content
            .quickLookPreview($previewURL, in: previewURLs)
            .task(id: app.openedBookingID) {
                guard let id = app.openedBookingID else { return }
                defer { app.openedBookingID = nil }
                if model.reservations.isEmpty { await model.load() }
                guard let reservation = model.reservations.first(where: { $0.id == id }) else { return }
                let urls = await model.localFiles(for: reservation)
                previewURLs = urls
                previewURL = urls.first
            }
    }
}

extension View {
    func bookingFilesPreview(model: TodayModel) -> some View {
        modifier(BookingFilesPreview(model: model))
    }
}
