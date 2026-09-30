import SwiftUI

struct JourneySettingsSection: View {
    @Environment(AppModel.self) private var app
    @Environment(\.scenePhase) private var scenePhase
    @State private var selection = JourneySelection()
    @State private var uploads: [JourneyUpload] = []
    @State private var isChoosing = false
    @State private var isSigningIn = false
    @State private var retryAnyway: JourneyUpload?
    @State private var cancelling: JourneyUpload?
    @State private var errorMessage: String?
    @State private var workingID: UUID?

    var body: some View {
        Section("Journey · \(app.account?.trip?.title ?? "Your trip")") {
            Button { isChoosing = true } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Select Journey")
                        Text(selection.selected?.title ?? "Choose where to share photos")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                }
            }
            if let error = selection.errorMessage {
                Text(error).font(.caption).foregroundStyle(.secondary)
            }
        }
        Section {
            ForEach(uploads) { upload in
                VStack(alignment: .leading, spacing: 8) {
                    Text(status(upload)).font(.subheadline.weight(.semibold))
                    Text("\(upload.destination.title) · \(upload.destination.tripTitle)")
                        .font(.caption).foregroundStyle(.secondary)
                    if let message = upload.photos.compactMap(\.message).first {
                        Text(message).font(.caption).foregroundStyle(.secondary)
                    }
                    HStack(spacing: 18) {
                        if upload.destination.scope != JourneySession.load()?.scope || upload.photos.contains(where: { $0.state == .signIn }) {
                            Button("Sign in") { isSigningIn = true }
                        } else if upload.photos.contains(where: { $0.state == .uncertain }) {
                            Button("Check upload") { retry(upload) }
                            Button("Send again") { retryAnyway = upload }
                        } else if upload.photos.contains(where: { $0.state != .uploading }) {
                            Button("Retry") { retry(upload) }
                        }
                        Button("Cancel upload", role: .destructive) { cancelling = upload }
                        if workingID == upload.id { ProgressView() }
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                    .disabled(workingID != nil)
                }
                .padding(.vertical, 4)
            }
            if uploads.isEmpty { Text("No pending photos").foregroundStyle(.secondary) }
            if let errorMessage { Text(errorMessage).font(.caption).foregroundStyle(Color.trekDanger) }
        } header: {
            Text("Journey uploads")
        } footer: {
            Text("Share photos from your gallery to Waypoint. Pending photos keep their original destination when you switch trips.")
        }
        .sheet(isPresented: $isChoosing) {
            NavigationStack {
                JourneyPickerView(selection: selection) { isChoosing = false }
                    .toolbar { Button("Close", systemImage: "xmark") { isChoosing = false } }
            }
        }
        .sheet(isPresented: $isSigningIn) {
            if let server = app.account?.serverURL {
                NavigationStack {
                    SignInStepView(serverURL: server) { account in
                        var account = account
                        if account.email.lowercased() == app.account?.email.lowercased() { account.trip = app.account?.trip }
                        app.account = account
                        isSigningIn = false
                        Task {
                            for upload in uploads where upload.destination.scope == JourneySession.load()?.scope {
                                retry(upload)
                            }
                            await selection.load()
                        }
                    }
                    .toolbar { Button("Close", systemImage: "xmark") { isSigningIn = false } }
                }
            }
        }
        .confirmationDialog("Send these photos again?", isPresented: Binding(get: { retryAnyway != nil }, set: { if !$0 { retryAnyway = nil } }), titleVisibility: .visible) {
            if let upload = retryAnyway { Button("Send again") { retry(upload, allowUncertain: true) } }
        } message: {
            Text("The earlier upload wasn't confirmed. If it reached TREK, sending again may create duplicates. Check the Journey gallery first.")
        }
        .confirmationDialog("Cancel this upload?", isPresented: Binding(get: { cancelling != nil }, set: { if !$0 { cancelling = nil } }), titleVisibility: .visible) {
            if let upload = cancelling {
                Button("Cancel upload", role: .destructive) {
                    Task {
                        do { try await JourneyUploader.cancel(upload); refresh() }
                        catch { errorMessage = error.localizedDescription }
                    }
                }
            }
        } message: {
            Text("Removes the pending copies from Waypoint. Photos already received by TREK remain in the Journey.")
        }
        .task(id: app.account?.trip?.id) {
            selection = JourneySelection()
            refresh()
            await selection.load()
        }
        .task {
            while !Task.isCancelled {
                if scenePhase == .active { refresh() }
                do { try await Task.sleep(for: .seconds(2)) } catch { break }
            }
        }
    }

    private func refresh() {
        do { uploads = try JourneyStore.shared().list() }
        catch { errorMessage = error.localizedDescription }
    }

    private func retry(_ upload: JourneyUpload, allowUncertain: Bool = false) {
        workingID = upload.id
        Task {
            defer { workingID = nil; refresh() }
            do {
                try await JourneyUploader.instance(JourneyUploader.appIdentifier).retry(upload.id, allowUncertain: allowUncertain)
                errorMessage = nil
            } catch { errorMessage = error.localizedDescription }
        }
    }

    private func status(_ upload: JourneyUpload) -> String {
        let count = upload.photos.count
        let photos = "\(count) \(count == 1 ? "photo" : "photos")"
        if upload.photos.contains(where: { $0.state == .signIn }) { return "Sign in to finish sending \(photos)" }
        if upload.photos.contains(where: { $0.state == .uncertain }) { return "\(photos) \(count == 1 ? "needs" : "need") upload confirmation" }
        if upload.photos.contains(where: { $0.state == .failed }) { return "\(photos) couldn't be sent" }
        if upload.photos.contains(where: { $0.state == .uploading }) { return "Sending \(photos) · Waiting for TREK" }
        return "\(photos) waiting to upload"
    }
}
