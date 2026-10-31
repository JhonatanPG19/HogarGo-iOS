import SwiftUI

struct HomeView: View {
    // Estados visuales de demostración
    @State private var isTaskCompleted: Bool = false
    @State private var streakDays: Int = 3
    @State private var showNewTaskSheet: Bool = false
    @State private var showNewExpenseSheet: Bool = false
    @State private var showNewEventSheet: Bool = false
    @State private var showMoreSheet: Bool = false
    @State private var showAboutSheet: Bool = false
    @State private var showMembersDialog: Bool = false

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

                // 5. Cuadrícula 2x2: Accesos rápidos (New Task, Add Expense, Event, More)
                QuickActionsGrid(
                    onNewTask: {
                        showNewTaskSheet = true
                        onNewTaskTap()
                    },
                    onAddExpense: {
                        showNewExpenseSheet = true
                        onAddExpenseTap()
                    },
                    onEvent: {
                        showNewEventSheet = true
                        onEventTap()
                    },
                    onMore: {
                        showMoreSheet = true
                        onMoreTap()
                    }
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
        .sheet(isPresented: $showNewExpenseSheet) {
            QuickAddExpenseSheet()
        }
        .sheet(isPresented: $showNewEventSheet) {
            QuickAddEventSheet()
        }
        .sheet(isPresented: $showMoreSheet) {
            MoreBottomSheet(
                onOpenAbout: {
                    showMoreSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showAboutSheet = true
                    }
                },
                onOpenMembers: {
                    showMoreSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showMembersDialog = true
                    }
                }
            )
            .presentationDetents([.fraction(0.38), .medium])
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutView()
        }
        .alert("Integrantes del Hogar", isPresented: $showMembersDialog) {
            Button("Cerrar", role: .cancel) {}
        } message: {
            Text("Miembros registrados en la familia:\n• Mamá (Admin)\n• Papá\n• Leo")
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

// MARK: - Cuadrícula 2x2: Accesos Rápidos
private struct QuickActionsGrid: View {
    var onNewTask: () -> Void
    var onAddExpense: () -> Void
    var onEvent: () -> Void
    var onMore: () -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            QuickActionButton(title: "New Task", icon: "checklist", action: onNewTask)
            QuickActionButton(title: "Add Expense", icon: "newspaper", action: onAddExpense)
            QuickActionButton(title: "Event", icon: "calendar", action: onEvent)
            QuickActionButton(title: "More", icon: "ellipsis", action: onMore)
        }
    }
}

private struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(HogarGoColors.surfaceContainerHigh)
                        .frame(width: 52, height: 52)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(HogarGoColors.primaryText)
                }

                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(HogarGoColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(HogarGoColors.borderSubtle.opacity(0.8), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - More Bottom Sheet (Fiel al Prototipo)
private struct MoreBottomSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onOpenAbout: () -> Void
    var onOpenMembers: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Indicador de arrastre / Handle
            HStack {
                Spacer()
                Capsule()
                    .fill(HogarGoColors.primaryText.opacity(0.4))
                    .frame(width: 38, height: 4.5)
                Spacer()
            }
            .padding(.top, 10)

            // Título "More"
            Text("More")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)
                .padding(.horizontal, 4)

            // Opciones
            VStack(spacing: 12) {
                // Opción 1: About HogarGo
                Button(action: onOpenAbout) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(HogarGoColors.surfaceContainerHigh)
                                .frame(width: 46, height: 46)
                            Image(systemName: "info.circle")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(HogarGoColors.primaryText)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text("About HogarGo")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
                            Text("App description and team credits")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(HogarGoColors.secondaryText)
                        }

                        Spacer()
                    }
                    .padding(14)
                    .background(HogarGoColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(HogarGoColors.borderSubtle.opacity(0.7), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                // Opción 2: Integrantes del Hogar
                Button(action: onOpenMembers) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(HogarGoColors.surfaceContainerHigh)
                                .frame(width: 46, height: 46)
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(HogarGoColors.primaryText)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Integrantes del Hogar")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
                            Text("Ver los miembros registrados de la familia")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(HogarGoColors.secondaryText)
                        }

                        Spacer()
                    }
                    .padding(14)
                    .background(HogarGoColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(HogarGoColors.borderSubtle.opacity(0.7), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .background(HogarGoColors.background.ignoresSafeArea())
    }
}

// MARK: - Modales rápidos auxiliares para Accesos Rápidos
private struct QuickAddExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var desc = ""
    @State private var amount = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Cancelar") { dismiss() }
                    .foregroundStyle(HogarGoColors.secondaryText)
                Spacer()
                Text("Añadir Gasto")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                Spacer()
                Button("Guardar") { dismiss() }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(HogarGoColors.brandOrangeDeep)
            }
            .padding(.top, 16)

            VStack(spacing: 14) {
                TextField("Descripción (ej. Comestibles)", text: $desc)
                    .padding(14)
                    .background(HogarGoColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                TextField("Monto (ej. 25.50)", text: $amount)
                    .keyboardType(.decimalPad)
                    .padding(14)
                    .background(HogarGoColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Spacer()
        }
        .padding(20)
        .background(HogarGoColors.background)
    }
}

private struct QuickAddEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Cancelar") { dismiss() }
                    .foregroundStyle(HogarGoColors.secondaryText)
                Spacer()
                Text("Nuevo Evento")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                Spacer()
                Button("Guardar") { dismiss() }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(HogarGoColors.brandOrangeDeep)
            }
            .padding(.top, 16)

            TextField("Título del evento (ej. Cena familiar)", text: $title)
                .padding(14)
                .background(HogarGoColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Spacer()
        }
        .padding(20)
        .background(HogarGoColors.background)
    }
}
