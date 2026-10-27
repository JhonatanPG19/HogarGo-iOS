import SwiftUI

struct HomeView: View {
    // Estados visuales de demostración
    @State private var isTaskCompleted: Bool = false
    @State private var streakDays: Int = 3
    @State private var showNewTaskSheet: Bool = false
    var onNewTaskTap: () -> Void = {}
    var onAddExpenseTap: () -> Void = {}
    var onEventTap: () -> Void = {}
    var onMoreTap: () -> Void = {}

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                // 1. Saludo y racha diaria
                VStack(alignment: .leading, spacing: 6) {
                    Text("¡Buenos días!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))

                    Text("Hagamos que hoy sea un día acogedor.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(HogarGoColors.secondaryText)

                    // Chip de Energía Diaria / Racha
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(HogarGoColors.brandOrange.opacity(0.2))
                                .frame(width: 32, height: 32)
                            Image(systemName: "flame.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(HogarGoColors.brandOrangeDeep)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Energía Diaria")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(HogarGoColors.primaryText)
                            Text("Racha de \(streakDays)/7 días")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(HogarGoColors.secondaryText)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(HogarGoColors.surface)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
                    )
                    .padding(.top, 4)
                }

                // 2. Tarjeta Héroe: Zori descansando
                ZoriRestingCard()

                // 3. Tarjeta: Siguiente Tarea
                NextTaskCard(isCompleted: $isTaskCompleted)

                // 4. Tarjeta: Meta de Ahorro
                SavingsGoalCard()

                // 5. Cuadrícula 2x2: Accesos rápidos
                QuickActionsGrid(
                    onNewTask: {
                        showNewTaskSheet = true
                        onNewTaskTap()
                    },
                    onAddExpense: onAddExpenseTap,
                    onEvent: onEventTap,
                    onMore: onMoreTap
                )

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(HogarGoColors.background)
        .sheet(isPresented: $showNewTaskSheet) {
            NewTaskView()
        }
    }
}

// MARK: - Subcomponentes de Inicio

/// Tarjeta principal de Zori descansando
private struct ZoriRestingCard: View {
    var body: some View {
        VStack(spacing: 12) {
            // Ilustración visual de Zori descansando
            ZStack {
                Circle()
                    .fill(HogarGoColors.brandOrangeContainer.opacity(0.4))
                    .frame(width: 140, height: 140)

                VStack(spacing: 4) {
                    Text("🦊")
                        .font(.system(size: 72))
                    Text("💤")
                        .font(.system(size: 20))
                        .offset(x: 35, y: -25)
                }
            }
            .padding(.top, 8)

            VStack(spacing: 6) {
                Text("Zori está descansando.")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)

                Text("¡Completa tareas para despertar a Zori y ganar las recompensas de hoy!")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(HogarGoColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            // Botón interactivo "Empezar Día"
            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 11))
                    Text("Empezar Día")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(HogarGoColors.primaryText)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(HogarGoColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
        )
    }
}

/// Tarjeta de próxima tarea pendiente
private struct NextTaskCard: View {
    @Binding var isCompleted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cabecera de la sección
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "paintbrush.pointed.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(HogarGoColors.primaryText)
                    Text("Siguiente Tarea")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(HogarGoColors.primaryText)
                }
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .fill(HogarGoColors.brandOrangeContainer.opacity(0.6))
                    .frame(width: 32, height: 12)
            }

            // Contenedor interior de la tarea
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isCompleted.toggle()
                }
            } label: {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: isCompleted ? "checkmark.square.fill" : "square")
                        .font(.system(size: 24))
                        .foregroundStyle(isCompleted ? HogarGoColors.brandOrangeDeep : HogarGoColors.outlineVariant)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lavar los platos")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .strikethrough(isCompleted, color: HogarGoColors.secondaryText)
                            .foregroundStyle(isCompleted ? HogarGoColors.secondaryText : Color(red: 34/255, green: 26/255, blue: 21/255))

                        Text("Cocina • 15 mins")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(HogarGoColors.secondaryText)
                    }
                    Spacer()
                }
                .padding(14)
                .background(HogarGoColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(HogarGoColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
        )
    }
}

/// Tarjeta de meta de ahorro
private struct SavingsGoalCard: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "airplane")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(HogarGoColors.primaryText)
                    Text("Fondo de Vacaciones")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(HogarGoColors.primaryText)
                }
                Spacer()
                Text("65%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(HogarGoColors.primaryText)
            }

            // Barra de progreso
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(HogarGoColors.surfaceContainer)
                        .frame(height: 8)

                    Capsule()
                        .fill(HogarGoColors.brandOrange)
                        .frame(width: proxy.size.width * 0.65, height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text("$650 ahorrado")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(HogarGoColors.secondaryText)
                Spacer()
                Text("Meta: $1000")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }
        }
        .padding(16)
        .background(HogarGoColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
        )
    }
}

/// Cuadrícula 2x2 con accesos rápidos
private struct QuickActionsGrid: View {
    var onNewTask: () -> Void
    var onAddExpense: () -> Void
    var onEvent: () -> Void
    var onMore: () -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            QuickActionButton(title: "Nueva Tarea", icon: "checkmark.circle", action: onNewTask)
            QuickActionButton(title: "Añadir Gasto", icon: "newspaper", action: onAddExpense)
            QuickActionButton(title: "Evento", icon: "calendar", action: onEvent)
            QuickActionButton(title: "Más", icon: "ellipsis", action: onMore)
        }
    }
}

private struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(HogarGoColors.brandOrangeContainer)
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(HogarGoColors.primaryText)
                }

                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(HogarGoColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

