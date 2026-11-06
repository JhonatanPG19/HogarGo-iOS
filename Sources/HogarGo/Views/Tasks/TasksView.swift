import SwiftUI

/// Pantalla de Tareas: envoltorio que resuelve el hogar activo.
struct TasksView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if let householdId = appState.householdId {
            TasksContent(householdId: householdId, appState: appState)
                .id(householdId)
        } else {
            Color.clear
        }
    }
}

private struct TasksContent: View {
    @State private var showNewTaskSheet: Bool = false

    // MVVM: el ViewModel guarda las tareas y calcula la racha; la vista solo las pinta.
    @State private var viewModel: TasksViewModel

    init(householdId: String, appState: AppState) {
        _viewModel = State(initialValue: TasksViewModel(
            householdId: householdId,
            taskRepository: appState.taskRepository,
            householdRepository: appState.repository
        ))
    }

    private var tasks: [HouseholdTask] { viewModel.tasks }
    private var streak: StreakInfo { viewModel.streak }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                // 1. Título y subtítulo
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.tr("Tareas", "Tasks"))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(HogarGoColors.primaryText)

                    Text(L10n.tr("Hagamos que el hogar brille hoy.", "Let's make the home shine today."))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(HogarGoColors.secondaryText)
                }

                // 2. Banner de racha actual
                StreakBannerView(days: streak.days, isAtRisk: streak.isAtRisk)

                // 3. Lista de tarjetas de tareas
                if tasks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checklist.checked")
                            .font(.system(size: 40))
                            .foregroundStyle(HogarGoColors.brandOrangeDeep.opacity(0.6))
                        Text(L10n.tr("No hay tareas pendientes", "No pending tasks"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(HogarGoColors.primaryText)
                        Text(L10n.tr("Crea una nueva misión desde el botón inferior.", "Create a new mission with the button below."))
                            .font(.system(size: 13))
                            .foregroundStyle(HogarGoColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(HogarGoColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    VStack(spacing: 16) {
                        ForEach(tasks) { task in
                            TaskRowCard(
                                task: task,
                                assigneeName: viewModel.assigneeName(for: task.assigneeId),
                                onToggle: {
                                    viewModel.toggle(task)
                                }
                            )
                        }
                    }
                }

                // 4. Botón punteado L10n.tr("Proponer Nueva Misión", "Propose a New Mission")
                Button {
                    showNewTaskSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text(L10n.tr("Proponer Nueva Misión", "Propose a New Mission"))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(HogarGoColors.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(HogarGoColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                HogarGoColors.outlineVariant,
                                style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                            )
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, 4)

                Spacer(minLength: 28)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(HogarGoColors.background)
        .onAppear { viewModel.start() }
        .sheet(isPresented: $showNewTaskSheet) {
            NewTaskView()
        }
    }
}

// MARK: - Banner de Racha
private struct StreakBannerView: View {
    let days: Int
    let isAtRisk: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 44, height: 44)
                Image(systemName: "flame.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(HogarGoColors.brandOrangeDeep)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.tr("RACHA ACTUAL", "CURRENT STREAK"))
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                    .tracking(0.5)

                Text(L10n.streakBanner(days, atRisk: isAtRisk))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(HogarGoColors.brandOrange)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Tarjeta de Fila de Tarea
private struct TaskRowCard: View {
    let task: HouseholdTask
    let assigneeName: String?
    let onToggle: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Contenedor principal de la tarjeta
            HStack(alignment: .top, spacing: 14) {
                // Checkbox interactivo
                Button(action: onToggle) {
                    Image(systemName: task.completed ? "checkmark.square.fill" : "square")
                        .font(.system(size: 26))
                        .foregroundStyle(task.completed ? HogarGoColors.brandOrangeDeep : HogarGoColors.outlineVariant)
                }
                .buttonStyle(.plain)
                .padding(.top, 2)

                // Información central
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .strikethrough(task.completed, color: HogarGoColors.secondaryText)
                        .foregroundStyle(task.completed ? HogarGoColors.secondaryText : Color(red: 34/255, green: 26/255, blue: 21/255))

                    if task.completed, let date = task.completedDate {
                        Text(L10n.tr("Completado (\(date))", "Completed (\(date))"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(HogarGoColors.secondaryText)
                    } else if let due = task.dueLabel {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text(due)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(HogarGoColors.secondaryText)
                    } else if let assignee = assigneeName {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 12))
                            Text(assignee)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(HogarGoColors.secondaryText)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2")
                                .font(.system(size: 12))
                            Text(L10n.tr("Sin asignar", "Unassigned"))
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(HogarGoColors.secondaryText)
                    }
                }

                Spacer()

                // Lado derecho: monedas y avatar
                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(task.coinReward) 🪙")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(HogarGoColors.primaryText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(HogarGoColors.surfaceContainer)
                        .clipShape(Capsule())

                    if let name = assigneeName {
                        HStack(spacing: 4) {
                            Text(name)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(HogarGoColors.secondaryText)
                            ZStack {
                                Circle()
                                    .fill(HogarGoColors.surfaceContainerHigh)
                                    .frame(width: 24, height: 24)
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(HogarGoColors.primaryText.opacity(0.8))
                            }
                        }
                    } else {
                        // Antes nunca se veía: la hora ocupaba siempre el lugar del texto "sin asignar".
                        HStack(spacing: 4) {
                            Image(systemName: "person.2")
                                .font(.system(size: 11))
                            Text(L10n.tr("Sin asignar", "Unassigned"))
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(HogarGoColors.secondaryText)
                    }
                }
            }
            .padding(.top, 22)
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
            .background(HogarGoColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
            )

            // Etiqueta de categoría en la esquina superior izquierda
            Text(categoryLabel(task.category))
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(HogarGoColors.surfaceContainer)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .offset(x: 12, y: -6)
        }
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
