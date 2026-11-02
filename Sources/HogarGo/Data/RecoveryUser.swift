import CryptoKit
import Foundation

/// Usuario de recuperación: segundo identificador, distinto del nombre.
/// Solo se guarda su hash; nunca el texto.
enum RecoveryUser {
    static let minLength = 4

    /// trim + minúsculas.
    static func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// SHA-256(normalize(texto)) en hexadecimal minúscula (64 caracteres).
    static func hash(_ text: String) -> String {
        SHA256.hash(data: Data(normalize(text).utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    /// Reglas 1 y 2. Devuelve `nil` si es válido.
    static func validate(_ text: String, name: String) -> HogarError? {
        let normalized = normalize(text)
        if normalized.count < minLength { return .recoveryUserInvalid }
        if normalized == Member.key(for: name) { return .recoveryUserSameAsName }
        return nil
    }
}
