import SwiftUI

/// 3.1 Crear hogar: quien lo crea queda como admin.
struct CreateHouseholdView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var householdName = ""
    @State private var recoveryUser = ""
    @State private var code = ""
    @State private var error: HogarError?

    private var recoveryError: String? { liveRecoveryError(recoveryUser, name: name) }

    private var canSubmit: Bool {
        !name.trimmed.isEmpty && !householdName.trimmed.isEmpty
            && !RecoveryUser.normalize(recoveryUser).isEmpty && recoveryError == nil
    }

    var body: some View {
        AccessSheet(title: L10n.createHome) {
            HogarTextField(label: L10n.yourName, placeholder: L10n.yourNamePlaceholder,
                           text: $name, error: error.message(for: .name))
            HogarTextField(label: L10n.homeName, placeholder: L10n.homeNamePlaceholder,
                           text: $householdName, error: error.message(for: .household))
            HogarTextField(label: L10n.recoveryLabel, placeholder: L10n.recoveryPlaceholder,
                           text: $recoveryUser, kind: .recoveryUser,
                           error: recoveryError ?? error.message(for: .recovery), help: L10n.recoveryHelp)

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.homeCode)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(HogarGoColors.primaryText)
                HStack {
                    HouseholdCodeBadge(code: code)
                    Spacer()
                    Button(L10n.regenerateCode) { code = appState.repository.suggestCode() }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(HogarGoColors.brandOrangeDeep)
                }
                .padding(14)
                .background(HogarGoColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                if let message = error.message(for: .code) {
                    Text(message)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(HogarGoColors.alertRed)
                }
            }

            HogarPrimaryButton(title: L10n.createAction, isEnabled: canSubmit, action: submit)
                .padding(.top, 6)
        }
        .onAppear { if code.isEmpty { code = appState.repository.suggestCode() } }
        .onChange(of: name) { error = nil }
        .onChange(of: householdName) { error = nil }
        .onChange(of: recoveryUser) { error = nil }
    }

    private func submit() {
        do {
            let member = try appState.repository.createHousehold(
                name: name, householdName: householdName, recoveryUser: recoveryUser, code: code
            )
            dismiss()
            appState.start(member)
        } catch let failure as HogarError {
            error = failure
            if failure == .codeTaken { code = appState.repository.suggestCode() }
        } catch {
            self.error = .unknown
        }
    }
}
