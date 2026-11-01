import SwiftUI

/// 3.3 Iniciar sesión con el nombre en el hogar o el usuario de recuperación.
struct LoginView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    var onForgotCode: () -> Void

    @State private var nameOrUser = ""
    @State private var code = ""
    @State private var error: HogarError?

    private var canSubmit: Bool { !nameOrUser.trimmed.isEmpty && !code.trimmed.isEmpty }

    var body: some View {
        AccessSheet(title: L10n.signIn) {
            HogarTextField(label: L10n.loginLabel, placeholder: L10n.loginPlaceholder,
                           text: $nameOrUser, kind: .recoveryUser,
                           error: error.message(for: .name) ?? error.message(for: .general))
            HogarTextField(label: L10n.homeCode, placeholder: "HGR-789",
                           text: $code, kind: .code, error: error.message(for: .code))

            Button(L10n.forgotCode, action: onForgotCode)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(HogarGoColors.brandOrangeDeep)

            HogarPrimaryButton(title: L10n.signIn, isEnabled: canSubmit, action: submit)
                .padding(.top, 6)
        }
        .onChange(of: nameOrUser) { error = nil }
        .onChange(of: code) { error = nil }
    }

    private func submit() {
        do {
            let member = try appState.repository.login(nameOrUser: nameOrUser, code: code)
            dismiss()
            appState.start(member)
        } catch let failure as HogarError {
            error = failure
        } catch {
            self.error = .unknown
        }
    }
}
