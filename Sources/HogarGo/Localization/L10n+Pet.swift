import Foundation

/// Textos de la mascota Zori (ES / EN).
extension L10n {
    static var petFeed: String { tr("Alimentar", "Feed") }
    static var petPlay: String { tr("Jugar", "Play") }
    static var petDecorate: String { tr("Decorar", "Decorate") }
    static var petStatusTitle: String { tr("Estado de Zori", "Zori's Status") }
    static func petLevel(_ n: Int) -> String { tr("Nvl \(n)", "Lvl \(n)") }
    static var petHappiness: String { tr("Felicidad", "Happiness") }
    static var petSatiety: String { tr("Saciedad", "Fullness") }
    static var petWardrobeTitle: String { tr("Armario", "Wardrobe") }
    static var petWardrobeSubtitle: String {
        tr("¡Cuida a Zori para subir de nivel y gana monedas con tareas para comprar nuevos objetos!",
           "Take care of Zori to level up and earn coins from tasks to buy new items!")
    }
    static var petWear: String { tr("Poner", "Wear") }
    static var petRemove: String { tr("Quitar", "Remove") }
    static func petBuy(_ price: Int) -> String { tr("Comprar · \(price) 🪙", "Buy · \(price) 🪙") }
    static func petCoinsBalance(_ n: Int) -> String { "🪙 \(n)" }
    static var petEquippedBadge: String { tr("Puesto", "Worn") }
    static var petWearing: String { tr("Zori lleva puesto:", "Zori is wearing:") }
    static var petWearingNothing: String { tr("Nada todavía. ¡Pulsa Decorar!", "Nothing yet. Tap Decorate!") }
    static func petLevelRequired(_ n: Int) -> String { tr("Nivel \(n) requerido", "Level \(n) required") }
    static var petTipTitle: String { tr("Sigue cuidando a Zori", "Keep taking care of Zori") }
    static var petTipSubtitle: String {
        tr("Aliméntalo y juega con él para subir de nivel y desbloquear nuevos objetos.",
           "Feed and play with Zori to level up and unlock new items.")
    }
    static func petCooldownAvailableIn(_ minutes: Int) -> String {
        tr("Disponible en \(minutes) min", "Available in \(minutes) min")
    }
}
