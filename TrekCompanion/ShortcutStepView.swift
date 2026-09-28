import SwiftUI

struct ShortcutStepView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    let onDone: () -> Void
    @State private var isAwaitingImport = false

    private let automationInstructions: [ShortcutInstruction] = [
        ShortcutInstruction(symbol: "square.stack.3d.up", text: "**Automation** → **+** → **Transaction**"),
        ShortcutInstruction(symbol: "creditcard", text: "Pick your cards, **Run Immediately**"),
        ShortcutInstruction(symbol: "checkmark", text: "Choose **Waypoint - TREK costs**"),
    ]

    private var isReady: Bool {
        model.shortcutCheck == .found
    }

    private var subtitle: String {
        guard isReady else { return "Waypoint - TREK costs logs every Apple Pay payment to your trip." }
        guard let title = model.account?.trip?.title else { return "Last thing: let Wallet run it on every payment." }
        return "Last thing: let Wallet run it on every payment into \(title)."
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                StepHeader(title: isReady ? "Shortcut added" : "Add the shortcut", subtitle: subtitle)
                ShortcutStatusCard(check: model.shortcutCheck)
                if isReady {
                    automationCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
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
            Button {
                openURL(URL(string: "shortcuts://")!)
            } label: {
                Label("Open Shortcuts", systemImage: "arrow.up.forward.app")
            }
            .buttonStyle(TrekButtonStyle())

            Button("Done") {
                model.isShortcutSetUp = true
                onDone()
            }
            .buttonStyle(TrekButtonStyle(kind: .secondary))
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

    private var automationCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(automationInstructions.enumerated()), id: \.offset) { index, instruction in
                ShortcutInstructionRow(instruction: instruction)
                if index < automationInstructions.count - 1 {
                    Divider().overlay(Color.trekDivider).padding(.leading, 48)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(Color.trekCard, in: .rect(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.trekBorder))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}
