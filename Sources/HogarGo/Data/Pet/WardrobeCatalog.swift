import Foundation

/// Objeto del catálogo del ropero de Zori.
struct WardrobeEntry: Identifiable {
    let id: String
    let emoji: String
    let unlockLevel: Int
    let price: Int
    let nameES: String
    let nameEN: String
    /// Centro (fracción del tamaño del avatar) y lado del objeto.
    let centerX: Double
    let centerY: Double
    let size: Double
    /// Se dibuja detrás del zorro.
    let behind: Bool

    var name: String { L10n.tr(nameES, nameEN) }
}

/// Catálogo fijo (el orden es el de la cuadrícula).
enum WardrobeCatalog {
    static let items: [WardrobeEntry] = [
        WardrobeEntry(
            id: "scarf", emoji: "🧣", unlockLevel: 1, price: 20,
            nameES: "Bufanda Acogedora", nameEN: "Cozy Scarf",
            centerX: 0.40, centerY: 0.57, size: 0.24, behind: false
        ),
        WardrobeEntry(
            id: "ball", emoji: "⚽", unlockLevel: 1, price: 30,
            nameES: "Pelota de Juguete", nameEN: "Toy Ball",
            centerX: 0.83, centerY: 0.82, size: 0.18, behind: false
        ),
        WardrobeEntry(
            id: "glasses", emoji: "🕶️", unlockLevel: 3, price: 60,
            nameES: "Gafas Inteligentes", nameEN: "Smart Glasses",
            centerX: 0.36, centerY: 0.39, size: 0.26, behind: false
        ),
        WardrobeEntry(
            id: "skateboard", emoji: "🛹", unlockLevel: 5, price: 100,
            nameES: "Mini Monopatín", nameEN: "Mini Skateboard",
            centerX: 0.50, centerY: 0.91, size: 0.36, behind: true
        ),
    ]

    static func entry(for id: String) -> WardrobeEntry? {
        items.first { $0.id == id }
    }
}
