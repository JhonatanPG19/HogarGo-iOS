import SwiftUI

struct TasksView: View {
    // Modelos visuales para demostración
    @State private var tasks: [TaskItemMock] = [
        TaskItemMock(
            id: "1",
            category: "COCINA",
            title: "Vaciar el Lavavajillas",
            timeLabel: "Para las 5 PM",
            isCompleted: false,
            rewardText: "15 🪙",
            assignedName: "Papá",
            avatarIcon: "person.crop.circle.fill"
        ),
        TaskItemMock(
            id: "2",
            category: "JARDÍN",
            title: "Regar los Tomates",
            completedByText: "Completado por Mamá",
            isCompleted: true,
            rewardText: "+20 ❤️"
        ),
        TaskItemMock(
            id: "3",
            category: "GENERAL",
            title: "Doblar la Ropa",
            unassigned: true,
            isCompleted: false,
            rewardText: "30 🪙"
        )
    ]

    @State private var showNewTaskSheet: Bool = false
    var onProposeNewTask: () -> Void = {}

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
                StreakBannerView(days: 4)

                // 3. Lista de tarjetas de tareas
                VStack(spacing: 16) {
                    ForEach($tasks) { $task in
                        TaskRowCard(task: $task)
                    }
                }

                // 4. Botón punteado "Proponer Nueva Misión"
                Button {
                    showNewTaskSheet = true
                    onProposeNewTask()
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
}

// MARK: - Banner de Racha
private struct StreakBannerView: View {
    let days: Int

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

                Text("¡\(days) Días Seguidos!")
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
    @Binding var task: TaskItemMock

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Contenedor principal de la tarjeta
            HStack(alignment: .top, spacing: 14) {
                // Checkbox interactivo
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        task.isCompleted.toggle()
                    }
                } label: {
                    Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                        .font(.system(size: 26))
                        .foregroundStyle(task.isCompleted ? HogarGoColors.brandOrangeDeep : HogarGoColors.outlineVariant)
                }
                .buttonStyle(.plain)
                .padding(.top, 2)

                // Información central
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .strikethrough(task.isCompleted, color: HogarGoColors.secondaryText)
                        .foregroundStyle(task.isCompleted ? HogarGoColors.secondaryText : Color(red: 34/255, green: 26/255, blue: 21/255))

                    if let completedBy = task.completedByText {
                        Text(completedBy)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(HogarGoColors.secondaryText)
                    } else if let time = task.timeLabel {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                            Text(time)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(HogarGoColors.secondaryText)
                    } else if task.unassigned {
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

                // Lado derecho: monedas y avatar si aplica
                VStack(alignment: .trailing, spacing: 8) {
                    Text(task.rewardText)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(HogarGoColors.primaryText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(HogarGoColors.surfaceContainer)
                        .clipShape(Capsule())

                    if let _ = task.assignedName {
                        ZStack {
                            Circle()
                                .fill(HogarGoColors.surfaceContainerHigh)
                                .frame(width: 26, height: 26)
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(HogarGoColors.primaryText.opacity(0.8))
                        }
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
            Text(task.category)
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(HogarGoColors.surfaceContainer)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .offset(x: 12, y: -6)
        }
    }
}

// MARK: - Modelo Mock para Tareas
struct TaskItemMock: Identifiable {
    let id: String
    var category: String
    var title: String
    var timeLabel: String? = nil
    var completedByText: String? = nil
    var unassigned: Bool = false
    var isCompleted: Bool
    var rewardText: String
    var assignedName: String? = nil
    var avatarIcon: String? = nil
}

