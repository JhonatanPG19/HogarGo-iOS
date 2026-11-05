import SwiftData
import SwiftUI

struct TasksView: View {
    @Environment(AppState.self) private var appState
    @State private var showNewTaskSheet: Bool = false

    // @Query se vuelve a evaluar solo al guardar en la base: una tarea nueva aparece al instante.
    @Query(sort: \HouseholdTask.createdAt, order: .reverse) private var allTasks: [HouseholdTask]

    private var householdTasks: [HouseholdTask] {
        guard let householdId = appState.householdId else { return [] }
        return allTasks.filter { $0.householdId == householdId }
    }

    /// Pendientes primero, luego las completadas; cada grupo de más reciente a más antigua.
    private var tasks: [HouseholdTask] {
        householdTasks.filter { !$0.completed } + householdTasks.filter(\.completed)
    }

    private var streak: StreakInfo {
        StreakCalculator.calculate(
            completedDates: householdTasks.filter(\.completed).compactMap(\.completedDate)
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                // 1. Título y subtítulo
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tareas")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(HogarGoColors.primaryText)

                    Text("Hagamos que el hogar brille hoy.")
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
                        Text("No hay tareas pendientes")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(HogarGoColors.primaryText)
                        Text("Crea una nueva misión desde el botón inferior.")
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
                                assigneeName: memberName(for: task.assigneeId),
                                onToggle: {
                                    _ = try? appState.taskRepository.toggleTask(id: task.id)
                                }
                            )
                        }
                    }
                }

                // 4. Botón punteado "Proponer Nueva Misión"
                Button {
                    showNewTaskSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("Proponer Nueva Misión")
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
        .sheet(isPresented: $showNewTaskSheet) {
            NewTaskView()
        }
    }

    private func memberName(for memberId: String?) -> String? {
        guard let memberId else { return nil }
        return appState.repository.member(id: memberId)?.name
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
                Text("RACHA ACTUAL")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                    .tracking(0.5)

                Text(days == 1 ? "¡1 Día Activo!" : "¡\(days) Días Seguidos!\(isAtRisk ? " ⚠️" : "")")
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
                        Text("Completado (\(date))")
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
                            Text("Sin asignar")
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
                            Text("Sin asignar")
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
        case .kitchen: return "COCINA"
        case .garden: return "JARDÍN"
        case .general: return "GENERAL"
        case .cleaning: return "LIMPIEZA"
        }
    }
}
