import SwiftUI

enum OnboardingStep: Int {
    case welcome, server, signIn, trip, shortcut

    static let count = 4
}

struct OnboardingView: View {
    @Environment(AppModel.self) private var model
    @State private var draftStep = OnboardingStep.welcome
    @State private var serverURL: URL?

    private var step: OnboardingStep {
        guard let account = model.account else { return draftStep }
        return account.trip == nil ? .trip : .shortcut
    }

    var body: some View {
        Group {
            if step == .welcome {
                WelcomeStepView { draftStep = .server }
            } else {
                VStack(spacing: 0) {
                    OnboardingProgressHeader(stepNumber: step.rawValue, total: OnboardingStep.count, onBack: goBack)
                    currentStep
                        .frame(maxHeight: .infinity, alignment: .top)
                }
                .background(Color.trekBackground)
            }
        }
        .animation(.smooth(duration: 0.3), value: step)
    }

    @ViewBuilder
    private var currentStep: some View {
        switch step {
        case .welcome:
            EmptyView()
        case .server:
            ServerStepView(initialURL: serverURL) { url in
                serverURL = url
                draftStep = .signIn
            }
        case .signIn:
            if let serverURL {
                SignInStepView(serverURL: serverURL) { model.account = $0 }
            }
        case .trip:
            TripStepView {}
        case .shortcut:
            ShortcutStepView {}
        }
    }

    private func goBack() {
        switch step {
        case .welcome, .server:
            draftStep = .welcome
        case .signIn:
            draftStep = .server
        case .trip:
            serverURL = model.account?.serverURL
            model.signOut()
            draftStep = .signIn
        case .shortcut:
            model.select(nil)
        }
    }
}
