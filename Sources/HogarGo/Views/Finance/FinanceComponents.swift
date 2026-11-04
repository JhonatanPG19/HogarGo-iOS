import SwiftUI

/// Tarjeta blanca con borde suave, igual a las del resto de pantallas.
extension View {
    func financeCard(radius: CGFloat = 24, padding: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .background(HogarGoColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(HogarGoColors.borderSubtle, lineWidth: 1)
            )
    }
}

extension ExpenseCategory {
    /// Color de la categoría (mismos valores que Android).
    var color: Color {
        switch self {
        case .groceries: return Color(red: 0x8D / 255, green: 0x4F / 255, blue: 0x11 / 255)
        case .bills: return Color(red: 0x90 / 255, green: 0x49 / 255, blue: 0x17 / 255)
        case .pet: return HogarGoColors.brandOrange
        case .leisure: return HogarGoColors.brandOrangeContainer
        case .other: return Color(red: 0xE4 / 255, green: 0xE3 / 255, blue: 0xDB / 255)
        }
    }

    /// Color del icono sobre `color` (claro sobre fondos oscuros, oscuro sobre claros).
    var iconColor: Color {
        switch self {
        case .groceries, .bills: return .white
        case .pet, .leisure, .other: return HogarGoColors.primaryText
        }
    }
}

/// Muestra un error de validación bajo un campo.
struct FinanceErrorText: View {
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(HogarGoColors.alertRed)
        }
    }
}

/// Campo de monto con prefijo "$" y teclado decimal.
struct AmountField: View {
    let label: String
    @Binding var text: String
    var error: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(HogarGoColors.primaryText)

            HStack(spacing: 6) {
                Text("$")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.brandOrangeDeep)
                TextField("0.00", text: $text)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(HogarGoColors.primaryText)
                    .onChange(of: text) { _, newValue in
                        let clean = FinanceFormat.sanitizeAmountInput(newValue)
                        if clean != newValue { text = clean }
                    }
            }
            .padding(14)
            .background(HogarGoColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(error == nil ? HogarGoColors.borderSubtle : HogarGoColors.alertRed, lineWidth: 1)
            )

            FinanceErrorText(message: error)
        }
    }
}
