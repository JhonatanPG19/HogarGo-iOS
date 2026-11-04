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
                HogarGoTopBar(onAvatarTap: { showProfile = true })

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

    private func tabPlaceholder(title: String, icon: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(HogarGoColors.brandOrange)
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)
        }
    }
}
