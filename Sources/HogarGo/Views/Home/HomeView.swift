import SwiftUI

/// Modales presentables desde la pantalla de Inicio mediante un único modifier `.sheet(item:)`.
enum HomeModalSheet: String, Identifiable {
    case newTask
    case newExpense
    case newEvent
    case more
    case about

    var id: String { rawValue }
}

struct HomeView: View {
    @Environment(AppState.self) private var appState

    // Estados de pantalla y modales
    @State private var activeSheet: HomeModalSheet? = nil
    @State private var showMembersDialog: Bool = false
    @State private var dailyAdvice: String = AdviceService.fallbackAdvice
    @State private var isFetchingAdvice: Bool = false

    private var nextPendingTask: HouseholdTask? {
        guard let householdId = appState.householdId else { return nil }
        return appState.taskRepository.nextPendingTask(householdId: householdId)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                // 1. Saludo y racha diaria
                VStack(alignment: .leading, spacing: 6) {
                    Text("¡Hola, \(appState.currentMember?.name ?? "Familia")!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))

                    Text("Hagamos que hoy sea un día acogedor.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(HogarGoColors.secondaryText)

                    // Chip de Energía Diaria / Racha
                    let streak = appState.currentStreak
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
                            Text("Racha de \(streak.days)/7 días\(streak.isAtRisk ? " ⚠️" : "")")
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

                // 2. Tarjeta: Consejo del Día (API en línea)
                DailyAdviceCard(
                    advice: dailyAdvice,
                    isLoading: isFetchingAdvice,
                    onRefresh: {
                        Task { await fetchAdvice() }
                    }
                )

                // 3. Tarjeta Héroe: Zori descansando
                ZoriRestingCard()

                // 4. Tarjeta: Siguiente Tarea (Persistencia real)
                NextTaskCard(
                    task: nextPendingTask,
                    onToggle: {
                        if let task = nextPendingTask {
                            appState.taskRepository.toggleTask(id: task.id)
                        }
                    }
                )

                // 5. Tarjeta: Meta de Ahorro
                SavingsGoalCard()

                // 6. Cuadrícula 2x2: Accesos rápidos (New Task, Add Expense, Event, More)
                QuickActionsGrid(
                    onNewTask: { activeSheet = .newTask },
                    onAddExpense: { activeSheet = .newExpense },
                    onEvent: { activeSheet = .newEvent },
                    onMore: { activeSheet = .more }
                )

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(HogarGoColors.background)
        .task {
            if dailyAdvice == AdviceService.fallbackAdvice {
                await fetchAdvice()
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .newTask:
                NewTaskView()
            case .newExpense:
                QuickAddExpenseSheet()
            case .newEvent:
                QuickAddEventSheet()
            case .more:
                MoreBottomSheet(
                    onOpenAbout: {
                        activeSheet = .about
                    },
                    onOpenMembers: {
                        activeSheet = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showMembersDialog = true
                        }
                    }
                )
                .presentationDetents([.fraction(0.38), .medium])
            case .about:
                AboutView()
            }
        }
        .alert("Integrantes del Hogar", isPresented: $showMembersDialog) {
            Button("Cerrar", role: .cancel) {}
        } message: {
            Text(membersSummary)
        }
    }

    private func fetchAdvice() async {
        isFetchingAdvice = true
        dailyAdvice = await AdviceService.shared.fetchDailyAdvice()
        isFetchingAdvice = false
    }

    private var membersSummary: String {
        let members = appState.householdId.map(appState.repository.approvedMembers(householdId:)) ?? []
        guard !members.isEmpty else {
            return "No hay integrantes registrados en este hogar todavía."
        }
        let lines = members.map { "• \($0.name)\($0.isAdmin ? " (Admin)" : "")" }
        return (["Miembros registrados en la familia:"] + lines).joined(separator: "\n")
    }
}

// MARK: - Subcomponentes de Inicio

/// Tarjeta del Consejo del Día consumido de la API externa
private struct DailyAdviceCard: View {
    let advice: String
    let isLoading: Bool
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(HogarGoColors.brandOrangeDeep)
                    Text("CONSEJO DEL DÍA")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundStyle(HogarGoColors.primaryText)
                        .tracking(0.5)
                }

                Spacer()

                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(HogarGoColors.primaryText)
                        .rotationEffect(.degrees(isLoading ? 360 : 0))
                        .animation(isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isLoading)
                        .padding(6)
                        .background(HogarGoColors.surfaceContainerHigh)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
            }

            Text("“\(advice)”")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)
                .lineSpacing(3)
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
    let task: HouseholdTask?
    let onToggle: () -> Void

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
                if let task {
                    Text(categoryLabel(task.category))
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundStyle(HogarGoColors.primaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(HogarGoColors.surfaceContainer)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
            }

            if let task {
                Button(action: onToggle) {
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: task.completed ? "checkmark.square.fill" : "square")
                            .font(.system(size: 24))
                            .foregroundStyle(task.completed ? HogarGoColors.brandOrangeDeep : HogarGoColors.outlineVariant)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))

                            Text("Para las \(task.dueTime ?? "18:00") • +\(task.coinReward) 🪙")
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
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(HogarGoColors.brandOrangeDeep)
                    Text("¡Todo al día! No hay tareas pendientes.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(HogarGoColors.secondaryText)
                    Spacer()
                }
                .padding(14)
                .background(HogarGoColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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

    private func categoryLabel(_ cat: TaskCategory) -> String {
        switch cat {
        case .kitchen: return "COCINA"
        case .garden: return "JARDÍN"
        case .general: return "GENERAL"
        case .cleaning: return "LIMPIEZA"
        }
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
