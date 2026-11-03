import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    // Campos del formulario
    @State private var taskTitle: String = ""
    @State private var selectedCategory: TaskCategoryOption = .kitchen
    @State private var selectedDate: String = "Hoy"
    @State private var selectedTime: String = "18:00"
    @State private var coinReward: Double = 15
    @State private var selectedAssigneeId: String? = nil
    @State private var errorMessage: String? = nil

    var onSave: () -> Void = {}

    private var members: [Member] {
        guard let householdId = appState.householdId else { return [] }
        return appState.repository.approvedMembers(householdId: householdId)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 1. Barra de navegación superior
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(HogarGoColors.primaryText)
                        .frame(width: 44, height: 44, alignment: .leading)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Nueva Tarea")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)

                Spacer()

                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 6)
            .background(HogarGoColors.background)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Mensaje de error si falla la validación
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.red)
                            .padding(.horizontal, 4)
                    }

                    // 2. Tarjeta "¿Qué hay que hacer?"
                    VStack(alignment: .leading, spacing: 10) {
                        Text("¿Qué hay que hacer?")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(HogarGoColors.primaryText)

                        TextField("Ej: Lavar los platos", text: $taskTitle)
                            .font(.system(size: 16))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .background(HogarGoColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
                            )
                    }
                    .padding(16)
                    .background(HogarGoColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
                    )

                    // 3. Categoría
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Categoría")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(HogarGoColors.primaryText)

                        HStack(spacing: 8) {
                            ForEach(TaskCategoryOption.allCases) { cat in
                                let isSelected = selectedCategory == cat
                                Button {
                                    selectedCategory = cat
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: cat.iconName)
                                            .font(.system(size: 18, weight: .semibold))
                                        Text(cat.rawValue)
                                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                                    }
                                    .foregroundStyle(isSelected ? HogarGoColors.primaryText : HogarGoColors.secondaryText)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isSelected ? HogarGoColors.brandOrange : HogarGoColors.surfaceContainerLow)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(HogarGoColors.borderSubtle, lineWidth: isSelected ? 0 : 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // 4. Fecha y Hora
                    HStack(spacing: 12) {
                        // Tarjeta Fecha
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 13))
                                Text("Fecha")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(HogarGoColors.primaryText)

                            Menu {
                                Button("Hoy") { selectedDate = "Hoy" }
                                Button("Mañana") { selectedDate = "Mañana" }
                                Button("Fin de semana") { selectedDate = "Fin de semana" }
                            } label: {
                                HStack {
                                    Text(selectedDate)
                                        .font(.system(size: 15, weight: .medium))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundStyle(HogarGoColors.primaryText)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(HogarGoColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
                                )
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(HogarGoColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        // Tarjeta Hora
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                    .font(.system(size: 13))
                                Text("Hora")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(HogarGoColors.primaryText)

                            Menu {
                                Button("09:00") { selectedTime = "09:00" }
                                Button("12:00") { selectedTime = "12:00" }
                                Button("18:00") { selectedTime = "18:00" }
                                Button("20:00") { selectedTime = "20:00" }
                            } label: {
                                HStack {
                                    Text(selectedTime)
                                        .font(.system(size: 15, weight: .medium))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundStyle(HogarGoColors.primaryText)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(HogarGoColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
                                )
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(HogarGoColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    // 5. Recompensa para Zori
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recompensa para Zori")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(HogarGoColors.primaryText)
                            Spacer()
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(HogarGoColors.brandOrangeContainer)
                        }

                        Slider(value: $coinReward, in: 5...50, step: 5)
                            .tint(HogarGoColors.brandOrangeDeep)

                        HStack {
                            Spacer()
                            Text("+\(Int(coinReward)) Monedas Zori")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(HogarGoColors.primaryText)
                            Spacer()
                        }
                    }
                    .padding(16)
                    .background(HogarGoColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
                    )

                    // 6. ¿Quién lo hará?
                    VStack(alignment: .leading, spacing: 12) {
                        Text("¿Quién lo hará?")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(HogarGoColors.primaryText)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(members) { member in
                                    AssigneeAvatarItem(
                                        name: member.name,
                                        icon: member.isAdmin ? "crown.fill" : "person.crop.circle.fill",
                                        isSelected: selectedAssigneeId == member.id,
                                        onSelect: {
                                            selectedAssigneeId = member.id
                                        }
                                    )
                                }

                                // Botón "Sin asignar"
                                Button {
                                    selectedAssigneeId = nil
                                } label: {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .strokeBorder(
                                                    selectedAssigneeId == nil ? HogarGoColors.brandOrangeDeep : HogarGoColors.outlineVariant,
                                                    style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])
                                                )
                                                .frame(width: 52, height: 52)

                                            Image(systemName: "person.crop.circle.badge.questionmark")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundStyle(HogarGoColors.primaryText)
                                        }

                                        Text("Cualquiera")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundStyle(HogarGoColors.primaryText)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }

            // 7. Botón "Crear Misión" al pie
            Button {
                saveTask()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 17, weight: .bold))
                    Text("Crear Misión")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(HogarGoColors.brandOrangeDeep)
                .clipShape(Capsule())
                .shadow(color: HogarGoColors.brandOrangeDeep.opacity(0.3), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(HogarGoColors.background)
        }
        .background(HogarGoColors.background)
        .onAppear {
            if selectedAssigneeId == nil {
                selectedAssigneeId = appState.memberId
            }
        }
    }

    private func saveTask() {
        let title = taskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            errorMessage = "Ingresa el nombre o descripción de la tarea."
            return
        }

        guard let householdId = appState.householdId else {
            errorMessage = "No hay un hogar activo seleccionado."
            return
        }

        let cat: TaskCategory
        switch selectedCategory {
        case .kitchen: cat = .kitchen
        case .garden: cat = .garden
        case .general: cat = .general
        case .cleaning: cat = .cleaning
        }

        do {
            try appState.taskRepository.createTask(
                householdId: householdId,
                title: title,
                category: cat,
                dueTime: selectedTime,
                assigneeId: selectedAssigneeId,
                coinReward: Int(coinReward)
            )
            onSave()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Enums y Componentes Auxiliares
enum TaskCategoryOption: String, CaseIterable, Identifiable {
    case kitchen = "COCINA"
    case garden = "JARDÍN"
    case general = "GENERAL"
    case cleaning = "LIMPIEZA"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .kitchen: return "frying.pan.fill"
        case .garden: return "leaf.fill"
        case .general: return "house.fill"
        case .cleaning: return "sparkles"
        }
    }
}

private struct AssigneeAvatarItem: View {
    let name: String
    let icon: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                ZStack(alignment: .bottomTrailing) {
                    ZStack {
                        Circle()
                            .fill(HogarGoColors.surfaceContainerHigh)
                            .frame(width: 52, height: 52)
                        Image(systemName: icon)
                            .font(.system(size: 22))
                            .foregroundStyle(HogarGoColors.primaryText.opacity(0.85))
                    }
                    .overlay(
                        Circle()
                            .stroke(isSelected ? HogarGoColors.brandOrangeDeep : Color.clear, lineWidth: 2)
                    )

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(HogarGoColors.brandOrangeDeep)
                            .background(Color.white.clipShape(Circle()))
                            .offset(x: 2, y: 2)
                    }
                }

                Text(name)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}
