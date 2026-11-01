import SwiftUI

/// Decide qué mostrar según la sesión: cargando, Bienvenida o Inicio.
struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            HogarGoColors.background
                .ignoresSafeArea()

            switch appState.phase {
            case .loading:
                Color.clear
            case .welcome:
                WelcomeView()
            case let .signedIn(_, householdId):
                // La clave por hogar evita mezclar datos entre hogares.
                MainTabsView()
                    .id(householdId)
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = appState.toast {
                ToastBanner(message: toast)
                    .padding(.bottom, 90)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: appState.toast)
        .task {
            if appState.phase == .loading { appState.restore() }
        }
    }
}
