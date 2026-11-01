import SwiftUI
import UIKit

/// Tipo de teclado para los campos de los formularios de hogar.
enum HogarFieldKind {
    /// Mayúscula en cada palabra.
    case name
    /// Sin autocapitalización ni autocorrección.
    case recoveryUser
    case code
}

/// Campo con etiqueta, error en vivo y texto de ayuda.
struct HogarTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var kind: HogarFieldKind = .name
    var error: String? = nil
    var help: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(HogarGoColors.primaryText)

            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium))
                .textInputAutocapitalization(capitalization)
                .autocorrectionDisabled(kind != .name)
                .padding(14)
                .background(HogarGoColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(error == nil ? HogarGoColors.borderSubtle : HogarGoColors.alertRed, lineWidth: 1)
                )

            if let error {
                Text(error)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(HogarGoColors.alertRed)
            } else if let help {
                Text(help)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(HogarGoColors.secondaryText)
            }
        }
    }

    private var capitalization: TextInputAutocapitalization {
        switch kind {
        case .name: return .words
        case .recoveryUser: return .never
        case .code: return .characters
        }
    }
}

/// Botón principal. Deshabilitado se ve atenuado y no responde al toque.
struct HogarPrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var isLoading: Bool = false
    var role: ButtonRole? = nil
    let action: () -> Void

    var body: some View {
        Button(role: role, action: action) {
            HStack(spacing: 8) {
                if isLoading { ProgressView().tint(.white) }
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(role == .destructive ? HogarGoColors.alertRed : HogarGoColors.brandOrangeDeep)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1 : 0.45)
    }
}

/// Código formateado (HGR-789) con botón para copiarlo.
struct HouseholdCodeBadge: View {
    @Environment(AppState.self) private var appState
    let code: String

    var body: some View {
        HStack(spacing: 10) {
            Text(HouseholdCode.format(code))
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(HogarGoColors.primaryText)
            Button {
                UIPasteboard.general.string = HouseholdCode.format(code)
                appState.showToast(L10n.copied)
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(HogarGoColors.brandOrangeDeep)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.copy)
        }
    }
}

struct ToastBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(HogarGoColors.primaryText.opacity(0.92))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
}

/// Encabezado de las hojas modales: título y botón de cerrar.
struct SheetHeader: View {
    @Environment(\.dismiss) private var dismiss
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(HogarGoColors.primaryText)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(HogarGoColors.secondaryText)
                    .frame(width: 34, height: 34)
                    .background(HogarGoColors.surfaceContainer)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.close)
        }
    }
}

extension HogarError {
    /// Mensaje del repositorio, solo si corresponde al campo indicado.
    func message(for field: Field) -> String? {
        self.field == field ? message : nil
    }
}

extension Optional where Wrapped == HogarError {
    func message(for field: HogarError.Field) -> String? {
        self?.message(for: field)
    }
}

/// Validación en vivo del usuario de recuperación al crear o unirse.
/// Vacío: sin mensaje (pero el botón queda deshabilitado).
func liveRecoveryError(_ text: String, name: String) -> String? {
    if RecoveryUser.normalize(text).isEmpty { return nil }
    return RecoveryUser.validate(text, name: name)?.message
}
