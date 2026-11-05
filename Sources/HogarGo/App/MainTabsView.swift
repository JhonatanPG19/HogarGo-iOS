import SwiftUI

/// Pestañas principales de la app con la sesión abierta.
struct MainTabsView: View {
    @State private var selectedTab: HogarGoTab = .home
    @State private var showProfile = false

    var body: some View {
        ZStack {
            HogarGoColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Barra superior permanente
                // El regalo lleva a Mascota, donde se gastan las monedas en el armario.
                HogarGoTopBar(
                    onAvatarTap: { showProfile = true },
                    onGiftTap: { selectedTab = .pet }
                )

                // Contenido dinámico según la pestaña seleccionada
                ZStack {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .tasks:
                        TasksView()
                    case .finance:
                        FinanceView()
                    case .pet:
                        PetView()
                    case .calendar:
                        CalendarView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Barra de navegación inferior
                HogarGoBottomBar(selectedTab: $selectedTab)
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
    }
}
