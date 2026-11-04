import Foundation

/// Conversión entre `Date` y el texto ISO "yyyy-MM-dd" que usan los modelos de Finanzas y Calendario.
/// Se crea un formateador por llamada para no compartir estado mutable entre hilos.
enum ISODay {
    private static func formatter() -> DateFormatter {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current
        df.dateFormat = "yyyy-MM-dd"
        return df
    }

    static func string(from date: Date) -> String {
        formatter().string(from: date)
    }

    static func date(from iso: String) -> Date? {
        formatter().date(from: iso)
    }

    static func today() -> String {
        string(from: Date())
    }

    /// "yyyy-MM" de una fecha ISO (o de hoy).
    static func monthKey(of iso: String) -> String {
        String(iso.prefix(7))
    }

    /// Fecha corta localizada tipo "12 mar" / "Mar 12".
    static func short(_ iso: String) -> String {
        guard let date = date(from: iso) else { return iso }
        let df = DateFormatter()
        df.locale = Locale(identifier: L10n.isEnglish ? "en" : "es")
        df.setLocalizedDateFormatFromTemplate("dMMM")
        return df.string(from: date)
    }
}
