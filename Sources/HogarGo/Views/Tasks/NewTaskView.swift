import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss

    // Estados visuales de formulario
    @State private var taskTitle: String = ""
    @State private var selectedCategory: TaskCategoryOption = .kitchen
    @State private var selectedDate: String = "Hoy"
    @State private var selectedTime: String = "18:00"
    @State private var coinReward: Double = 30
    @State private var selectedAssignee: String = "Mamá"

    var onSave: () -> Void = {}

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

                // Espacio para equilibrar el botón de retroceso
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 6)
            .background(HogarGoColors.background)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
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

                    // 4. Fecha y Hora en paralelo
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

                        // Slider nativo estilizado
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

                        HStack(spacing: 16) {
                            AssigneeAvatarItem(
                                name: "Mamá",
                                icon: "person.crop.circle.fill",
                                isSelected: selectedAssignee == "Mamá",
                                onSelect: { selectedAssignee = "Mamá" }
                            )

                            AssigneeAvatarItem(
                                name: "Leo",
                                icon: "figure.child",
                                isSelected: selectedAssignee == "Leo",
                                onSelect: { selectedAssignee = "Leo" }
                            )

                            AssigneeAvatarItem(
                                name: "Papá",
                                icon: "person.fill",
                                isSelected: selectedAssignee == "Papá",
                                onSelect: { selectedAssignee = "Papá" }
                            )

                            // Botón "Otro" punteado
                            Button {
                                selectedAssignee = "Otro"
                            } label: {
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .strokeBorder(
                                                selectedAssignee == "Otro" ? HogarGoColors.brandOrangeDeep : HogarGoColors.outlineVariant,
                                                style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])
                                            )
                                            .frame(width: 52, height: 52)

                                        Image(systemName: "plus")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(HogarGoColors.primaryText)
                                    }

                                    Text("Otro")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(HogarGoColors.primaryText)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }

            // 7. Botón "Crear Misión" al pie
            Button {
                onSave()
                dismiss()
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
                            .font(.system(size: 26))
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
            }
        }
        .buttonStyle(.plain)
    }
}

