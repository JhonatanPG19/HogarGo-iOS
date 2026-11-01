import SwiftUI

/// 3.4 Ver los códigos de mis hogares con el usuario de recuperación.
struct RecoverCodesView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var recoveryUser = ""
    @State private var results: [HouseholdRepository.RecoveredHome]?
    @State private var isLoading = false
    @FocusState private var focused: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SheetHeader(title: L10n.recoverTitle)

                    Text(L10n.recoverDescription)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(HogarGoColors.secondaryText)

                    HogarTextField(label: L10n.recoveryLabel, placeholder: L10n.recoveryPlaceholder,
                                   text: $recoveryUser, kind: .recoveryUser)
                        .focused($focused)

                    HogarPrimaryButton(title: L10n.showCodes,
                                       isEnabled: !recoveryUser.trimmed.isEmpty,
                                       isLoading: isLoading) {
                        search(proxy: proxy)
                    }

                    Group {
                        if let results {
                            if results.isEmpty {
                                Text(L10n.recoverEmpty)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(HogarGoColors.secondaryText)
                            } else {
                                ForEach(results) { home in
                                    RecoveredHomeCard(home: home) { enter(home) }
                                }
                            }
                        }
                    }
                    .id("results")
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(HogarGoColors.background.ignoresSafeArea())
    }

    private func search(proxy: ScrollViewProxy) {
        focused = false
        isLoading = true
        Task { @MainActor in
            // Pequeña pausa para que se vea el indicador y el teclado termine de cerrarse.
            try? await Task.sleep(for: .milliseconds(250))
            results = appState.repository.recoverHomes(recoveryUser: recoveryUser)
            isLoading = false
            withAnimation { proxy.scrollTo("results", anchor: .top) }
        }
    }

    private func enter(_ home: HouseholdRepository.RecoveredHome) {
        guard let member = try? appState.repository.login(nameOrUser: home.memberName, code: home.code) else {
            results = []
            return
        }
        dismiss()
        appState.start(member)
    }
}

private struct RecoveredHomeCard: View {
    let home: HouseholdRepository.RecoveredHome
    let onEnter: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(home.isAdmin ? "\(home.householdName) · \(L10n.adminBadge)" : home.householdName)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)
            Text(L10n.registeredAs(home.memberName))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(HogarGoColors.secondaryText)
            HStack {
                HouseholdCodeBadge(code: home.code)
                Spacer()
                Button(L10n.enter, action: onEnter)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(HogarGoColors.brandOrangeDeep)
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(HogarGoColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
        )
    }
}
