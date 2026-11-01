import SwiftUI

struct RootView: View {
    @State private var selectedTab: HogarGoTab = .home

    var body: some View {
        ZStack {
            HogarGoColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Barra superior permanente
                HogarGoTopBar()

                // Contenido dinámico según la pestaña seleccionada
                ZStack {
                    switch selectedTab {
                    case .home:
                        HomeView(
                            onNewTaskTap: { selectedTab = .tasks }
                        )
                    case .tasks:
                        TasksView()
                    case .finance:
                        FinanceView()
                    case .pet:
                        tabPlaceholder(title: "Mascota", icon: "pawprint.fill")
                    case .calendar:
                        CalendarView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Barra de navegación inferior
                HogarGoBottomBar(selectedTab: $selectedTab)
            }
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
