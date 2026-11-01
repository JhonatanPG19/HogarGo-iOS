import SwiftUI

/// 3.2 Unirse a un hogar: queda pendiente hasta que el admin acepte.
struct JoinHouseholdView: View {
    @Environment(AppState.self) private var appState

    @State private var name = ""
    @State private var recoveryUser = ""
    @State private var code = ""
    @State private var error: HogarError?
    @State private var requestSent = false

    private var recoveryError: String? { liveRecoveryError(recoveryUser, name: name) }

    private var canSubmit: Bool {
        !name.trimmed.isEmpty && !RecoveryUser.normalize(recoveryUser).isEmpty
            && recoveryError == nil && !code.trimmed.isEmpty
    }

    var body: some View {
        AccessSheet(title: L10n.joinHome) {
            if requestSent {
                RequestSentCard()
            }

            HogarTextField(label: L10n.yourName, placeholder: L10n.yourNamePlaceholder,
                           text: $name, error: error.message(for: .name))
            HogarTextField(label: L10n.recoveryLabel, placeholder: L10n.recoveryPlaceholder,
                           text: $recoveryUser, kind: .recoveryUser,
                           error: recoveryError ?? error.message(for: .recovery), help: L10n.recoveryHelp)
            HogarTextField(label: L10n.homeCode, placeholder: "HGR-789",
                           text: $code, kind: .code, error: error.message(for: .code))

            HogarPrimaryButton(title: L10n.joinAction, isEnabled: canSubmit, action: submit)
                .padding(.top, 6)
        }
        .onChange(of: name) { fieldsEdited() }
        .onChange(of: recoveryUser) { fieldsEdited() }
        .onChange(of: code) { fieldsEdited() }
    }

    private func fieldsEdited() {
        error = nil
        requestSent = false
    }

    private func submit() {
        do {
            try appState.repository.joinHousehold(name: name, recoveryUser: recoveryUser, code: code)
            withAnimation { requestSent = true }
        } catch let failure as HogarError {
            error = failure
        } catch {
            self.error = .unknown
        }
    }
}

private struct RequestSentCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 20))
                .foregroundStyle(HogarGoColors.success)
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.requestSentTitle)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                Text(L10n.requestSentBody)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HogarGoColors.success.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
