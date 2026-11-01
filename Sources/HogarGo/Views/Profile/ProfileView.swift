import SwiftData
import SwiftUI

/// 4. Diálogo de Perfil: mis datos, el hogar, integrantes y acciones del admin.
struct ProfileView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if let memberId = appState.memberId, let householdId = appState.householdId {
            ProfileContent(memberId: memberId, householdId: householdId)
        }
    }
}

private struct ProfileContent: View {
    private enum Editor: String, Identifiable {
        case myName, recoveryUser, householdName
        var id: String { rawValue }
    }

    @Environment(AppState.self) private var appState
    @Query private var members: [Member]
    @Query private var households: [Household]

    let memberId: String
    @State private var editor: Editor?
    @State private var memberToRemove: Member?
    @State private var confirmLeave = false
    @State private var actionError: HogarError?

    init(memberId: String, householdId: String) {
        self.memberId = memberId
        _members = Query(filter: #Predicate<Member> { $0.householdId == householdId }, sort: \Member.createdAt)
        _households = Query(filter: #Predicate<Household> { $0.id == householdId })
    }

    /// El rol se lee del integrante vivo, no de la sesión (puede cambiar por traspaso).
    private var me: Member? { members.first { $0.id == memberId } }
    private var household: Household? { households.first }
    private var isAdmin: Bool { me?.isAdmin == true && me?.isApproved == true }
    private var approved: [Member] { members.filter(\.isApproved) }
    private var pending: [Member] { members.filter { !$0.isApproved } }

    var body: some View {
        ScrollView {
            if let me, let household {
                VStack(alignment: .leading, spacing: 20) {
                    SheetHeader(title: L10n.profile)
                    header(me: me, household: household)
                    if isAdmin && !pending.isEmpty { pendingSection }
                    membersSection
                    recoveryRow(me: me)
                    if let actionError {
                        Text(actionError.message)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(HogarGoColors.alertRed)
                    }
                    VStack(spacing: 10) {
                        HogarPrimaryButton(title: L10n.leaveHome, role: .destructive) { confirmLeave = true }
                        Button(L10n.logout) { appState.logout() }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(HogarGoColors.primaryText)
                            .padding(.vertical, 8)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(20)
            }
        }
        .background(HogarGoColors.background.ignoresSafeArea())
        .sheet(item: $editor) { editor in
            if let me, let household {
                switch editor {
                case .myName: ChangeNameView(member: me, members: members)
                case .recoveryUser: ChangeRecoveryUserView(member: me)
                case .householdName: RenameHouseholdView(actorId: me.id, household: household)
                }
            }
        }
        .alert(
            memberToRemove.map { L10n.removeTitle($0.name) } ?? "",
            isPresented: Binding(get: { memberToRemove != nil }, set: { if !$0 { memberToRemove = nil } }),
            presenting: memberToRemove
        ) { member in
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.remove, role: .destructive) {
                run { try appState.repository.removeMember(actorId: memberId, memberId: member.id) }
            }
        } message: { _ in
            Text(L10n.removeBody)
        }
        .alert(L10n.leaveHomeTitle(household?.name ?? ""), isPresented: $confirmLeave) {
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.leave, role: .destructive) {
                run { try appState.leaveHousehold() }
            }
        } message: {
            Text(leaveMessage)
        }
    }

    private var leaveMessage: String {
        guard isAdmin else { return L10n.leaveMemberBody }
        return approved.count > 1 ? L10n.leaveAdminBody : L10n.leaveLastBody
    }

    private func run(_ action: () throws -> Void) {
        do {
            try action()
            actionError = nil
        } catch let error as HogarError {
            actionError = error
        } catch {
            actionError = .unknown
        }
    }

    // MARK: - Secciones

    private func header(me: Member, household: Household) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                MemberAvatar(name: me.name, size: 56)
                VStack(alignment: .leading, spacing: 4) {
                    editableTitle(me.name, size: 22) { editor = .myName }
                    if isAdmin {
                        Text(L10n.adminBadge)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(HogarGoColors.brandOrangeDeep)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.homeName.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(HogarGoColors.secondaryText)
                if isAdmin {
                    editableTitle(household.name, size: 18) { editor = .householdName }
                } else {
                    Text(household.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(HogarGoColors.primaryText)
                }
                Text(L10n.homeCode.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(HogarGoColors.secondaryText)
                    .padding(.top, 4)
                HouseholdCodeBadge(code: household.code)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(HogarGoColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private func editableTitle(_ text: String, size: CGFloat, onEdit: @escaping () -> Void) -> some View {
        Button(action: onEdit) {
            HStack(spacing: 8) {
                Text(text)
                    .font(.system(size: size, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(HogarGoColors.brandOrangeDeep)
            }
        }
        .buttonStyle(.plain)
    }

    private var pendingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(L10n.pendingRequests(pending.count))
            ForEach(pending) { member in
                HStack(spacing: 12) {
                    MemberAvatar(name: member.name, size: 36)
                    Text(member.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(HogarGoColors.primaryText)
                    Spacer()
                    circleButton("xmark", color: HogarGoColors.alertRed, label: L10n.reject) {
                        run { try appState.repository.rejectRequest(actorId: memberId, memberId: member.id) }
                    }
                    circleButton("checkmark", color: HogarGoColors.success, label: L10n.accept) {
                        run { try appState.repository.acceptRequest(actorId: memberId, memberId: member.id) }
                    }
                }
                .padding(12)
                .background(HogarGoColors.brandOrangeContainer.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(L10n.members)
            ForEach(approved) { member in
                HStack(spacing: 12) {
                    MemberAvatar(name: member.name, size: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(member.id == memberId ? "\(member.name) (\(L10n.you))" : member.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(HogarGoColors.primaryText)
                        if member.isAdmin {
                            Text(L10n.adminBadge)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(HogarGoColors.brandOrangeDeep)
                        }
                    }
                    Spacer()
                    if isAdmin && !member.isAdmin {
                        Button { memberToRemove = member } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(HogarGoColors.alertRed)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(L10n.remove)
                    }
                }
                .padding(12)
                .background(HogarGoColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private func recoveryRow(me: Member) -> some View {
        Button { editor = .recoveryUser } label: {
            HStack(spacing: 12) {
                Image(systemName: "key.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(HogarGoColors.brandOrangeDeep)
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.recoveryLabel)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(HogarGoColors.primaryText)
                    Text(me.hasRecoveryUser ? L10n.recoveryConfigured : L10n.recoveryNotConfigured)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(HogarGoColors.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }
            .padding(14)
            .background(HogarGoColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(HogarGoColors.primaryText)
    }

    private func circleButton(_ icon: String, color: Color, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(color)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

/// Círculo con la inicial del integrante.
struct MemberAvatar: View {
    let name: String
    var size: CGFloat = 40

    var body: some View {
        Text(String(name.prefix(1)).uppercased())
            .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
            .foregroundStyle(HogarGoColors.primaryText)
            .frame(width: size, height: size)
            .background(HogarGoColors.brandOrangeContainer)
            .clipShape(Circle())
    }
}
