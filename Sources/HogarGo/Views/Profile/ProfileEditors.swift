import SwiftUI

/// 7.1 Cambiar mi nombre (solo en este hogar).
struct ChangeNameView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let member: Member
    /// Integrantes del hogar, incluidas las solicitudes pendientes.
    let members: [Member]

    @State private var newName = ""
    @State private var error: HogarError?

    private var liveError: String? {
        let name = newName.trimmed
        if name.isEmpty { return nil }
        if member.hasRecoveryUser && RecoveryUser.hash(name) == member.recoveryKey {
            return HogarError.nameSameAsRecoveryUser.message
        }
        let key = Member.key(for: name)
        if members.contains(where: { $0.id != member.id && $0.nameKey == key }) {
            return HogarError.nameTaken.message
        }
        return nil
    }

    private var canSave: Bool {
        !newName.trimmed.isEmpty && liveError == nil && newName.trimmed != member.name
    }

    var body: some View {
        AccessSheet(title: L10n.changeMyName) {
            Text(L10n.currentName(member.name))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(HogarGoColors.secondaryText)
            HogarTextField(label: L10n.newName, placeholder: member.name, text: $newName,
                           error: liveError ?? error?.message, help: L10n.nameOnlyHere)
            HogarPrimaryButton(title: L10n.save, isEnabled: canSave) {
                do {
                    try appState.repository.changeMyName(memberId: member.id, newName: newName)
                    appState.showToast(L10n.nameUpdated)
                    dismiss()
                } catch {
                    self.error = error as? HogarError ?? .unknown
                }
            }
        }
        .onChange(of: newName) { error = nil }
        .presentationDetents([.medium, .large])
    }
}

/// 7.2 Cambiar o crear el usuario de recuperación.
struct ChangeRecoveryUserView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let member: Member

    @State private var current = ""
    @State private var new = ""
    @State private var repeatNew = ""
    @State private var error: HogarError?

    private var hasCurrent: Bool { member.hasRecoveryUser }

    private var currentError: String? {
        guard hasCurrent, !current.trimmed.isEmpty else { return nil }
        return RecoveryUser.hash(current) == member.recoveryKey ? nil : HogarError.recoveryCurrentWrong.message
    }

    private var newError: String? {
        guard !RecoveryUser.normalize(new).isEmpty else { return nil }
        if let error = RecoveryUser.validate(new, name: member.name) { return error.message }
        if hasCurrent && RecoveryUser.hash(new) == member.recoveryKey { return HogarError.recoverySameAsCurrent.message }
        return nil
    }

    /// Aparece mientras se escribe la repetición.
    private var repeatError: String? {
        guard !repeatNew.trimmed.isEmpty else { return nil }
        return RecoveryUser.normalize(repeatNew) == RecoveryUser.normalize(new) ? nil : HogarError.recoveryMismatch.message
    }

    private var canSave: Bool {
        let filled = (!hasCurrent || !current.trimmed.isEmpty) && !new.trimmed.isEmpty && !repeatNew.trimmed.isEmpty
        return filled && currentError == nil && newError == nil && repeatError == nil
    }

    var body: some View {
        AccessSheet(title: L10n.recoveryLabel) {
            Text(hasCurrent ? L10n.recoveryChangeHelp : L10n.recoveryHelp)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(HogarGoColors.secondaryText)
            if hasCurrent {
                HogarTextField(label: L10n.recoveryCurrent, placeholder: "", text: $current,
                               kind: .recoveryUser, error: currentError)
            }
            HogarTextField(label: L10n.recoveryNew, placeholder: L10n.recoveryPlaceholder, text: $new,
                           kind: .recoveryUser, error: newError)
            HogarTextField(label: L10n.recoveryRepeat, placeholder: "", text: $repeatNew,
                           kind: .recoveryUser, error: repeatError ?? error?.message)
            HogarPrimaryButton(title: L10n.save, isEnabled: canSave) {
                do {
                    try appState.repository.changeRecoveryUser(
                        memberId: member.id, current: current, new: new, repeatNew: repeatNew
                    )
                    appState.showToast(L10n.usernameSaved)
                    dismiss()
                } catch {
                    self.error = error as? HogarError ?? .unknown
                }
            }
        }
        .onChange(of: current) { error = nil }
        .onChange(of: new) { error = nil }
        .onChange(of: repeatNew) { error = nil }
    }
}

/// 5. Cambiar el nombre del hogar (solo admin).
struct RenameHouseholdView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let actorId: String
    let household: Household

    @State private var name = ""
    @State private var error: HogarError?

    var body: some View {
        AccessSheet(title: L10n.renameHome) {
            HogarTextField(label: L10n.homeName, placeholder: household.name, text: $name,
                           error: error?.message)
            HogarPrimaryButton(title: L10n.save, isEnabled: !name.trimmed.isEmpty && name.trimmed != household.name) {
                do {
                    try appState.repository.renameHousehold(actorId: actorId, householdId: household.id, newName: name)
                    appState.showToast(L10n.homeRenamed)
                    dismiss()
                } catch {
                    self.error = error as? HogarError ?? .unknown
                }
            }
        }
        .onAppear { if name.isEmpty { name = household.name } }
        .onChange(of: name) { error = nil }
        .presentationDetents([.medium])
    }
}
