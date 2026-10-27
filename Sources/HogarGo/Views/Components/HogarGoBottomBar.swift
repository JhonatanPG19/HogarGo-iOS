import SwiftUI

enum HogarGoTab: String, CaseIterable, Identifiable {
    case home = "Inicio"
    case tasks = "Tareas"
    case finance = "Finanzas"
    case pet = "Mascota"
    case calendar = "Calendario"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .tasks: return "checklist"
        case .finance: return "banknote.fill"
        case .pet: return "pawprint.fill"
        case .calendar: return "calendar"
        }
    }
}

struct HogarGoBottomBar: View {
    @Binding var selectedTab: HogarGoTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HogarGoTab.allCases) { tab in
                let isSelected = selectedTab == tab
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    }
                    .foregroundStyle(isSelected ? HogarGoColors.primaryText : HogarGoColors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    .background(
                        Group {
                            if isSelected {
                                Capsule()
                                    .fill(HogarGoColors.brandOrange)
                                    .frame(height: 52)
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            HogarGoColors.background
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .fill(HogarGoColors.borderSubtle.opacity(0.6))
                .frame(height: 1),
            alignment: .top
        )
    }
}

