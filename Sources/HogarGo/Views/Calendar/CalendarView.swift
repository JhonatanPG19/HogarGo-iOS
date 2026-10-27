import SwiftUI

struct CalendarView: View {
    @State private var selectedDay: Int = 15
    @State private var currentMonth: String = "Octubre 2023"
    @State private var isTask1Completed: Bool = false
    @State private var isTask2Completed: Bool = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                // 1. Título y subtítulo centrado
                VStack(spacing: 4) {
                    Text("Calendario")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(HogarGoColors.primaryText)

                    Text("Un resumen cálido de los ritmos de tu mes.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(HogarGoColors.secondaryText)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 4)

                // 2. Tarjeta del Calendario Mensual
                MonthCalendarGridCard(selectedDay: $selectedDay, currentMonth: currentMonth)

                // 3. Tarjeta: "Próximas Tareas"
                UpcomingTasksCard(
                    isTask1Completed: $isTask1Completed,
                    isTask2Completed: $isTask2Completed
                )

                // 4. Tarjeta: "Vencimiento de Facturas"
                BillsDueCard()

                Spacer(minLength: 28)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .background(HogarGoColors.background)
    }
}

// MARK: - Tarjeta de Cuadrícula del Mes
private struct MonthCalendarGridCard: View {
    @Binding var selectedDay: Int
    let currentMonth: String

    private let daysOfWeek = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
    // Estructura de días para Octubre (comienza en Domingo día 1)
    private let daysInMonth = Array(1...31)
    private let daysWithOrangeDot = [3, 8, 12, 15, 22, 28]
    private let daysWithPeachDot = [1, 15, 30]

    var body: some View {
        VStack(spacing: 14) {
            // Cabecera del mes con flechas de navegación
            HStack {
                HStack(spacing: 6) {
                    Text(currentMonth)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
                    Text("📅")
                        .font(.system(size: 16))
                }

                Spacer()

                HStack(spacing: 8) {
                    Button(action: {}) {
                        Circle()
                            .fill(HogarGoColors.surfaceContainerHigh.opacity(0.6))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(HogarGoColors.primaryText)
                            )
                    }
                    .buttonStyle(.plain)

                    Button(action: {}) {
                        Circle()
                            .fill(HogarGoColors.surfaceContainerHigh.opacity(0.6))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(HogarGoColors.primaryText)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Días de la semana
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(HogarGoColors.secondaryText)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 4)

            // Cuadrícula de números
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { day in
                    let isSelected = selectedDay == day
                    let hasOrange = daysWithOrangeDot.contains(day)
                    let hasPeach = daysWithPeachDot.contains(day)

                    Button {
                        selectedDay = day
                    } label: {
                        VStack(spacing: 3) {
                            Text("\(day)")
                                .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                                .foregroundStyle(isSelected ? HogarGoColors.brandOrangeDeep : Color(red: 34/255, green: 26/255, blue: 21/255))

                            // Puntos indicadores
                            HStack(spacing: 3) {
                                if hasOrange {
                                    Circle()
                                        .fill(HogarGoColors.brandOrange)
                                        .frame(width: 4, height: 4)
                                }
                                if hasPeach {
                                    Circle()
                                        .fill(HogarGoColors.brandOrangeContainer)
                                        .frame(width: 4, height: 4)
                                }
                            }
                            .frame(height: 4)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(
                            Group {
                                if isSelected {
                                    HogarGoColors.brandOrangeContainer.opacity(0.5)
                                } else {
                                    HogarGoColors.surfaceContainerLow.opacity(0.6)
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(isSelected ? HogarGoColors.brandOrangeDeep : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(HogarGoColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Tarjeta de Próximas Tareas
private struct UpcomingTasksCard: View {
    @Binding var isTask1Completed: Bool
    @Binding var isTask2Completed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "paintbrush.pointed.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(HogarGoColors.primaryText)

                Text("Próximas Tareas")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
            }

            VStack(spacing: 12) {
                // Tarea 1
                UpcomingTaskRow(
                    title: "Aspirar el Salón",
                    timeInfo: "Hoy, 4 PM",
                    isCompleted: $isTask1Completed
                )

                // Tarea 2
                UpcomingTaskRow(
                    title: "Regar las Plantas",
                    timeInfo: "Mañana",
                    isCompleted: $isTask2Completed
                )
            }
        }
        .padding(16)
        .background(HogarGoColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
        )
    }
}

private struct UpcomingTaskRow: View {
    let title: String
    let timeInfo: String
    @Binding var isCompleted: Bool

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isCompleted.toggle()
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isCompleted ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22))
                    .foregroundStyle(isCompleted ? HogarGoColors.brandOrangeDeep : HogarGoColors.outlineVariant)
                    .padding(.top, 1)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .strikethrough(isCompleted, color: HogarGoColors.secondaryText)
                        .foregroundStyle(isCompleted ? HogarGoColors.secondaryText : Color(red: 34/255, green: 26/255, blue: 21/255))

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(timeInfo)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(HogarGoColors.secondaryText)
                }

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tarjeta de Vencimiento de Facturas
private struct BillsDueCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "newspaper.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 170/255, green: 30/255, blue: 30/255))

                Text("Vencimiento de Facturas")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 170/255, green: 30/255, blue: 30/255))
            }

            VStack(spacing: 12) {
                // Factura 1: Electricidad (¡Vence Hoy!)
                BillRowItem(
                    title: "Electricidad",
                    subtitle: "¡Vence Hoy!",
                    subtitleColor: Color(red: 186/255, green: 26/255, blue: 26/255),
                    amount: "$124.50",
                    icon: "bolt.fill",
                    iconBg: Color(red: 255/255, green: 218/255, blue: 214/255),
                    iconColor: Color(red: 147/255, green: 0/255, blue: 10/255)
                )

                // Factura 2: Internet (Oct 20)
                BillRowItem(
                    title: "Internet",
                    subtitle: "Oct 20",
                    subtitleColor: HogarGoColors.secondaryText,
                    amount: "$79.99",
                    icon: "wifi",
                    iconBg: HogarGoColors.brandOrangeContainer,
                    iconColor: HogarGoColors.brandOrangeDeep
                )
            }
        }
        .padding(16)
        .background(HogarGoColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
        )
    }
}

private struct BillRowItem: View {
    let title: String
    let subtitle: String
    let subtitleColor: Color
    let amount: String
    let icon: String
    let iconBg: Color
    let iconColor: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconBg)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
                Text(subtitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(subtitleColor)
            }

            Spacer()

            Text(amount)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
        }
        .padding(14)
        .background(HogarGoColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

