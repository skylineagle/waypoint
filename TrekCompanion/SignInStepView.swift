import SwiftUI

struct SignInStepView: View {
    let serverURL: URL
    let onSignedIn: (Account) -> Void
    @State private var email = ""
    @State private var password = ""
    @State private var code = ""
    @State private var mfaToken: String?
    @State private var isWorking = false
    @State private var errorMessage: String?

    private var canSubmit: Bool {
        guard !isWorking else { return false }
        return mfaToken == nil ? !email.isEmpty && !password.isEmpty : code.count >= 6
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                StepHeader(
                    title: mfaToken == nil ? "Sign in" : "Enter your code",
                    subtitle: mfaToken == nil ? nil : "Open your authenticator app and enter the code for TREK."
                )
                ServerChip(host: serverURL.host() ?? serverURL.absoluteString)

                if mfaToken == nil {
                    credentialFields
                } else {
                    TrekTextField(symbol: "lock.shield", placeholder: "6-digit code", text: $code, focusOnAppear: true)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                }

                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.circle")
                        .font(.poppins(13, relativeTo: .footnote))
                        .foregroundStyle(Color.trekDanger)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .stepActions {
            Button(action: submit) {
                HStack(spacing: 8) {
                    if isWorking {
                        ProgressView().tint(Color.trekAccentText)
                    } else {
                        Image(systemName: mfaToken == nil ? "airplane.departure" : "checkmark.shield")
                    }
                    Text(mfaToken == nil ? "Sign In" : "Verify")
                }
            }
            .buttonStyle(TrekButtonStyle())
            .disabled(!canSubmit)
        }
    }

    private var credentialFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel(text: "Email")
            TrekTextField(symbol: "envelope", placeholder: "your@email.com", text: $email, focusOnAppear: true, accessibilityLabel: "Email")
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            FieldLabel(text: "Password")
                .padding(.top, 8)
            TrekTextField(symbol: "lock", placeholder: "••••••••", text: $password, isSecure: true, accessibilityLabel: "Password")
                .textContentType(.password)
                .submitLabel(.go)
                .onSubmit(submit)
        }
    }

    private func submit() {
        guard canSubmit else { return }
        isWorking = true
        errorMessage = nil
        Task {
            defer { isWorking = false }
            do {
                if let mfaToken {
                    onSignedIn(try await TrekClient.verifyCode(code, mfaToken: mfaToken, serverURL: serverURL, email: email, password: password))
                    return
                }
                switch try await TrekClient.signIn(serverURL: serverURL, email: email, password: password) {
                case .signedIn(let account): onSignedIn(account)
                case .needsCode(let token): mfaToken = token
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
