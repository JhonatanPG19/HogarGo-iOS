import SwiftUI

struct FinanceView: View {
    @State private var showNewExpenseSheet: Bool = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                // 1. Título, subtítulo y botón "+ Nuevo Gasto"
                VStack(alignment: .leading, spacing: 6) {
                    Text("El Cofre Comunitario")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(HogarGoColors.primaryText)

                    Text("El latido financiero de nuestra familia.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(HogarGoColors.secondaryText)

                    Button {
                        showNewExpenseSheet = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .bold))
                            Text("Nuevo Gasto")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(HogarGoColors.primaryText)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }

                // 2. Tarjeta Héroe: Fondo para Disneyland
                SavingsGoalHeroCard()

                // 3. Tarjeta: "Este Mes" (Gastado / Restante)
                MonthMetricsCard()

                // 4. Tarjeta: "Desglose de Gastos"
                ExpenseBreakdownCard()

                // 5. Tarjeta: "Gastos Recientes"
                RecentExpensesCard()

                Spacer(minLength: 28)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(HogarGoColors.background)
        .sheet(isPresented: $showNewExpenseSheet) {
            NewExpenseModalView()
        }
    }
}

// MARK: - Subcomponentes de Finanzas

/// Tarjeta héroe con la ilustración del cofre / hucha
private struct SavingsGoalHeroCard: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Fondo para Disneyland")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)

            Text("$1,300 / $2,000")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(HogarGoColors.secondaryText)

            // Ilustración estilizada del Cofre / Tarro de monedas
            ZStack(alignment: .top) {
                // Cuerpo del cofre / tarro
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                HogarGoColors.brandOrange,
                                HogarGoColors.brandOrangeDeep
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 130, height: 140)
                    .overlay(
                        // Reflejo de luz en el lateral
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 12, height: 100)
                            .padding(.leading, 12),
                        alignment: .leading
                    )

                // Tapa superior del cofre
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(red: 232/255, green: 228/255, blue: 220/255))
                    .frame(width: 110, height: 18)
                    .offset(y: 4)
            }
            .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 16)
        .background(HogarGoColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
        )
    }
}

/// Métricas de Gastado y Restante en dos columnas
private struct MonthMetricsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Este Mes")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))

            HStack(spacing: 14) {
                // Gastado
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "chart.line.downtrend.xyaxis")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(HogarGoColors.primaryText)
                        Text("Gastado")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(HogarGoColors.secondaryText)
                    }

                    Text("$3,420")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(HogarGoColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                // Restante
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "wallet.pass")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(HogarGoColors.primaryText)
                        Text("Restante")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(HogarGoColors.secondaryText)
                    }

                    Text("$1,080")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(HogarGoColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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

/// Tarjeta de desglose por categoría
private struct ExpenseBreakdownCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Desglose de Gastos")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))

            VStack(spacing: 12) {
                BreakdownRow(category: "Comestibles", amount: "$850", progress: 0.65, fillColor: HogarGoColors.brandOrangeDeep)
                BreakdownRow(category: "Servicios y Facturas", amount: "$420", progress: 0.40, fillColor: HogarGoColors.primaryText)
                BreakdownRow(category: "Cuidado de Mascota", amount: "$150", progress: 0.18, fillColor: HogarGoColors.brandOrange)
                BreakdownRow(category: "Ocio y Cenas", amount: "$300", progress: 0.28, fillColor: HogarGoColors.brandOrangeContainer)
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

private struct BreakdownRow: View {
    let category: String
    let amount: String
    let progress: Double
    let fillColor: Color

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(category)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(red: 45/255, green: 35/255, blue: 30/255))
                Spacer()
                Text(amount)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(HogarGoColors.surfaceContainerHigh.opacity(0.6))
                        .frame(height: 8)

                    Capsule()
                        .fill(fillColor)
                        .frame(width: proxy.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

/// Lista de gastos recientes
private struct RecentExpensesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Gastos Recientes")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))

                Spacer()

                Button("Ver Todo") {}
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.brandOrangeDeep)
                    .buttonStyle(.plain)
            }

            VStack(spacing: 14) {
                RecentExpenseRow(
                    title: "Trader Joe's",
                    category: "Comestibles",
                    amount: "-$142.50",
                    date: "Ayer",
                    icon: "cart.fill",
                    iconBg: HogarGoColors.brandOrange
                )

                RecentExpenseRow(
                    title: "Happy Paws Vet",
                    category: "Cuidado de Mascota",
                    amount: "-$85.00",
                    date: "Lun, 12",
                    icon: "pawprint.fill",
                    iconBg: HogarGoColors.brandOrangeContainer
                )

                RecentExpenseRow(
                    title: "City Electric",
                    category: "Servicios",
                    amount: "-$120.00",
                    date: "Dom, 11",
                    icon: "bolt.fill",
                    iconBg: HogarGoColors.brandOrangeDeep
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

private struct RecentExpenseRow: View {
    let title: String
    let category: String
    let amount: String
    let date: String
    let icon: String
    let iconBg: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconBg)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
                Text(category)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(amount)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 34/255, green: 26/255, blue: 21/255))
                Text(date)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }
        }
    }
}

/// Modal simple para "+ Nuevo Gasto"
private struct NewExpenseModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var descriptionText: String = ""
    @State private var amountText: String = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Cancelar") { dismiss() }
                    .foregroundStyle(HogarGoColors.secondaryText)
                Spacer()
                Text("Nuevo Gasto")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                Spacer()
                Button("Guardar") { dismiss() }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(HogarGoColors.brandOrangeDeep)
            }
            .padding(.top, 16)

            VStack(spacing: 14) {
                TextField("Descripción (ej. Supermercado)", text: $descriptionText)
                    .padding(14)
                    .background(HogarGoColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                TextField("Monto (ej. 45.00)", text: $amountText)
                    .keyboardType(.decimalPad)
                    .padding(14)
                    .background(HogarGoColors.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            Spacer()
        }
        .padding(20)
        .background(HogarGoColors.background)
    }
}

