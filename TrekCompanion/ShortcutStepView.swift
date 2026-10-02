import SwiftUI

struct ShortcutStepView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    let onDone: () -> Void
    @State private var isAwaitingImport = false

    private var isReady: Bool {
        model.shortcutCheck == .found
    }

    private var subtitle: String {
        guard isReady else { return "\(TrekShortcut.name) adds every Apple Pay payment to your trip." }
        guard let title = model.account?.trip?.title else { return "Payments on any card are added to your trip." }
        return "Payments on any card are added to \(title)."
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                StepHeader(title: isReady ? "Shortcut added" : "Add the shortcut", subtitle: subtitle)
                ShortcutStatusCard(check: model.shortcutCheck)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .animation(.smooth, value: isReady)
        }
        .scrollBounceBehavior(.basedOnSize)
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            if isAwaitingImport {
                isAwaitingImport = false
                model.shortcutCheck = .found
            }
        }
        .stepActions { actions }
    }

    @ViewBuilder
    private var actions: some View {
        switch model.shortcutCheck {
        case .idle:
            addButton
            Button("I already have it") { model.shortcutCheck = .found }
                .buttonStyle(TrekButtonStyle(kind: .secondary))
        case .found:
            Button("Done") {
                model.isShortcutSetUp = true
                onDone()
            }
            .buttonStyle(TrekButtonStyle())
        }
    }

    private var addButton: some View {
        Button {
            isAwaitingImport = true
            openURL(TrekShortcut.link)
        } label: {
            Label("Add Shortcut", systemImage: "plus")
        }
        .buttonStyle(TrekButtonStyle())
    }

}
