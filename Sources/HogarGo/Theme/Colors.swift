import SwiftUI

/// Paleta de colores oficial de HogarGo basada en los prototipos y el tema de diseño.
enum HogarGoColors {
    // Fondos principales
    static let background = Color(red: 254/255, green: 248/255, blue: 245/255) // #FEF8F5 - Crema cálido
    static let surface = Color.white
    static let surfaceContainer = Color(red: 252/255, green: 234/255, blue: 226/255) // #FCEAE2 - Melocotón suave
    static let surfaceContainerHigh = Color(red: 246/255, green: 229/255, blue: 221/255)
    static let surfaceContainerLow = Color(red: 255/255, green: 241/255, blue: 235/255)

    // Colores de marca
    static let primaryText = Color(red: 122/255, green: 62/255, blue: 29/255) // #7A3E1D - Marrón cálido
    static let secondaryText = Color(red: 140/255, green: 116/255, blue: 104/255) // #8C7468
    static let brandOrange = Color(red: 254/255, green: 172/255, blue: 103/255) // #FEAC67 - Naranja vibrante
    static let brandOrangeContainer = Color(red: 255/255, green: 219/255, blue: 201/255) // #FFDBC9
    static let brandOrangeDeep = Color(red: 151/255, green: 68/255, blue: 0/255) // #974400 - Terracota / Botón primario

    // Bordes y separadores
    static let borderSubtle = Color(red: 235/255, green: 220/255, blue: 212/255)
    static let outlineVariant = Color(red: 215/255, green: 194/255, blue: 184/255)

    // Acentos de estado
    static let success = Color(red: 85/255, green: 139/255, blue: 47/255)
    static let alertRed = Color(red: 186/255, green: 26/255, blue: 26/255)
}

