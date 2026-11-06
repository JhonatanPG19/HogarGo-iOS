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

/// Pantalla de Inicio: envoltorio que resuelve el hogar activo.
struct HomeView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if let householdId = appState.householdId {
            HomeContent(householdId: householdId, appState: appState)
                .id(householdId)
        } else {
            Color.clear
        }
    }
}

private struct HomeContent: View {
    @Environment(AppState.self) private var appState

    // Estados de pantalla y modales
    @State private var activeSheet: HomeModalSheet? = nil
    @State private var showMembersDialog: Bool = false

    // MVVM: Inicio compone ViewModels. `HomeViewModel` maneja tareas, racha y la llamada a la API;
    // los otros dos alimentan las tarjetas de Zori y de la meta de ahorro.
    @State private var viewModel: HomeViewModel
    @State private var petViewModel: PetViewModel
    @State private var financeViewModel: FinanceViewModel

    init(householdId: String, appState: AppState) {
        _viewModel = State(initialValue: HomeViewModel(
            householdId: householdId,
            memberId: appState.memberId,
            taskRepository: appState.taskRepository,
            householdRepository: appState.repository
        ))
        _petViewModel = State(initialValue: PetViewModel(
            householdId: householdId,
            repository: appState.petRepository
        ))
        _financeViewModel = State(initialValue: FinanceViewModel(
            householdId: householdId,
            repository: appState.financeRepository
        ))
    }

    private var nextPendingTask: HouseholdTask? { viewModel.nextPendingTask }
    private var streak: StreakInfo { viewModel.streak }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                // 1. Saludo y racha diaria
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.homeGreeting(viewModel.currentMemberName))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))

                    Text(L10n.tr("Hagamos que hoy sea un día acogedor.", "Let's make today a cozy day."))
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
                            Text(L10n.tr("Energía Diaria", "Daily Energy"))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(HogarGoColors.primaryText)
                            Text(L10n.homeStreak(streak.days, atRisk: streak.isAtRisk))
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
                    advice: viewModel.advice,
                    isLoading: viewModel.isFetchingAdvice,
                    onRefresh: {
                        Task { await viewModel.refreshAdvice() }
                    }
                )

                // 3. Tarjeta Héroe: Zori (estado real de la mascota)
                HomeZoriCard(viewModel: petViewModel)

                // 4. Tarjeta: Siguiente Tarea (Persistencia real)
                NextTaskCard(
                    task: nextPendingTask,
                    onToggle: {
                        // Se completa exactamente la tarea que muestra la tarjeta.
                        viewModel.toggleNextTask()
                    }
                )

                // 5. Tarjeta: Meta de Ahorro (real, si existe)
                HomeGoalCard(viewModel: financeViewModel)

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
        .onAppear {
            viewModel.start()
            petViewModel.start()
            financeViewModel.start()
        }
        .task {
            await viewModel.loadAdviceIfNeeded()
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .newTask:
                NewTaskView()
            case .newExpense:
                if let householdId = appState.householdId {
                    AddExpenseSheet(householdId: householdId)
                }
            case .newEvent:
                if let householdId = appState.householdId {
                    AddEventSheet(householdId: householdId, initialDate: Date(), onCreated: { _ in })
                }
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
        .alert(L10n.tr("Integrantes del Hogar", "Home Members"), isPresented: $showMembersDialog) {
            Button(L10n.close, role: .cancel) {}
        } message: {
            Text(viewModel.membersSummary)
        }
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
                    Text(L10n.tr("CONSEJO DEL DÍA", "DAILY TIP"))
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
                    Text(L10n.tr("Siguiente Tarea", "Next Task"))
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

                            Text("\(task.dueLabel ?? L10n.taskDueAt("18:00")) • +\(task.coinReward) 🪙")
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
                    Text(L10n.tr("¡Todo al día! No hay tareas pendientes.", "All caught up! No pending tasks."))
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
        case .kitchen: return L10n.tr("COCINA", "KITCHEN")
        case .garden: return L10n.tr("JARDÍN", "GARDEN")
        case .general: return L10n.tr("GENERAL", "GENERAL")
        case .cleaning: return L10n.tr("LIMPIEZA", "CLEANING")
        }
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
            QuickActionButton(title: L10n.tr("Nueva Tarea", "New Task"), icon: "checklist", action: onNewTask)
            QuickActionButton(title: L10n.tr("Añadir Gasto", "Add Expense"), icon: "newspaper", action: onAddExpense)
            QuickActionButton(title: L10n.tr("Evento", "Event"), icon: "calendar", action: onEvent)
            QuickActionButton(title: L10n.tr("Más", "More"), icon: "ellipsis", action: onMore)
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
            Text(L10n.tr("Más", "More"))
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
                            Text(L10n.tr("Acerca de HogarGo", "About HogarGo"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
                            Text(L10n.tr("Descripción de la app y créditos del equipo", "App description and team credits"))
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
                            Text(L10n.tr("Integrantes del Hogar", "Home Members"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
                            Text(L10n.tr("Ver los miembros registrados de la familia", "See the family members who are registered"))
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
