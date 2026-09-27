import SwiftUI

struct ServerStepView: View {
    let initialURL: URL?
    let onContinue: (URL) -> Void
    @State private var address: String
    @State private var status = ServerStatus.idle

    init(initialURL: URL?, onContinue: @escaping (URL) -> Void) {
        self.initialURL = initialURL
        self.onContinue = onContinue
        _address = State(initialValue: initialURL?.host() ?? "")
    }

    private var serverURL: URL? {
        let trimmed = address.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        return URL(string: trimmed.contains("://") ? trimmed : "https://\(trimmed)")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            StepHeader(title: "Where's your Trek?", subtitle: "The address you open TREK at in your browser.")

            VStack(alignment: .leading, spacing: 10) {
                TrekTextField(symbol: "globe", placeholder: "trek.example.com", text: $address, focusOnAppear: true, accessibilityLabel: "Server address")
                    .keyboardType(.URL)
                    .textContentType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.continue)
                    .onSubmit(proceed)
                ServerStatusLabel(status: status)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .task(id: address) { await check() }
        .stepActions {
            Button("Continue", action: proceed)
                .buttonStyle(TrekButtonStyle())
                .disabled(status != .found)
        }
    }

    private func check() async {
        guard let serverURL else {
            status = .idle
            return
        }
        try? await Task.sleep(for: .milliseconds(450))
        guard !Task.isCancelled else { return }
        status = .checking
        let isTrek = await TrekClient.isTrekServer(serverURL)
        guard !Task.isCancelled else { return }
        status = isTrek ? .found : .notFound
    }

    private func proceed() {
        guard status == .found, let serverURL else { return }
        onContinue(serverURL)
    }
}
