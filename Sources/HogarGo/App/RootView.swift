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
        .hogarToast(bottomPadding: 90)
        .task {
            if appState.phase == .loading { appState.restore() }
        }
    }
}
