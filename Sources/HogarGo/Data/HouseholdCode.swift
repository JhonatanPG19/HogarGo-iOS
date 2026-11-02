import Foundation

/// Código de invitación del hogar: se muestra como "HGR-789" y se guarda como "HGR789".
enum HouseholdCode {
    static let length = 6
    // Sin caracteres confusos: sin I, O, 0, 1.
    static let letters = Array("ABCDEFGHJKLMNPQRSTUVWXYZ")
    static let digits = Array("23456789")

    /// Quita todo lo que no sea letra o número y pasa a mayúsculas.
    static func normalize(_ text: String) -> String {
        String(text.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) && $0.isASCII }).uppercased()
    }

    static func isValid(_ normalized: String) -> Bool {
        normalized.count == length
    }

    /// 3 letras + 3 números.
    static func random() -> String {
        let l = (0..<3).map { _ in letters.randomElement()! }
        let d = (0..<3).map { _ in digits.randomElement()! }
        return String(l + d)
    }

    static func format(_ code: String) -> String {
        let normalized = normalize(code)
        guard normalized.count == length else { return normalized }
        return "\(normalized.prefix(3))-\(normalized.suffix(3))"
    }
}
