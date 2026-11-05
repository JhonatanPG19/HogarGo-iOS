import SwiftUI

/// Pantalla de Bienvenida: crear un hogar, unirse o iniciar sesión.
struct WelcomeView: View {
    private enum Sheet: String, Identifiable {
        case create, join, login, recover
        var id: String { rawValue }
    }

    @State private var sheet: Sheet?

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(HogarGoColors.brandOrangeContainer)
                        .frame(width: 120, height: 120)
                    Image(systemName: "house.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(HogarGoColors.brandOrangeDeep)
                }
                Text("HogarGo")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                Text(L10n.welcomeSubtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 12) {
                HogarPrimaryButton(title: L10n.createHome) { sheet = .create }

                Button { sheet = .join } label: {
                    Text(L10n.joinHome)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(HogarGoColors.brandOrangeDeep)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(HogarGoColors.brandOrangeContainer)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button { sheet = .login } label: {
                    Text(L10n.signIn)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(HogarGoColors.primaryText)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .create:
                CreateHouseholdView()
            case .join:
                JoinHouseholdView()
            case .login:
                LoginView(onForgotCode: { switchSheet(to: .recover) })
            case .recover:
                RecoverCodesView()
            }
        }
    }

    /// Cierra la hoja actual y abre otra.
    private func switchSheet(to next: Sheet) {
        sheet = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { sheet = next }
    }
}

/// Contenedor común de las hojas de acceso.
struct AccessSheet<Content: View, Footer: View>: View {
    let title: String
    let content: Content
    /// Botón principal: queda fijo abajo y sube junto con el teclado, así nunca se tapa.
    let footer: Footer

    init(
        title: String,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.title = title
        self.content = content()
        self.footer = footer()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SheetHeader(title: title)
                content
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            footer
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(HogarGoColors.background)
        }
        .background(HogarGoColors.background.ignoresSafeArea())
        .hogarToast()
    }
}

extension AccessSheet where Footer == EmptyView {
    /// Hoja sin botón fijo (los botones van dentro del contenido).
    init(title: String, @ViewBuilder content: () -> Content) {
        self.init(title: title, content: content, footer: { EmptyView() })
    }
}
