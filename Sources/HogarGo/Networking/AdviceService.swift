import Foundation

/// Estructura de respuesta devuelta por la API pública https://api.adviceslip.com/advice
struct AdviceSlip: Codable, Equatable, Sendable {
    let id: Int
    let advice: String
}

struct AdviceResponse: Codable, Sendable {
    let slip: AdviceSlip
}

/// Servicio de red para consultar consejos diarios desde la API externa AdviceSlip.
/// Implementa manejo de red con URLSession, decodificación Codable y el mensaje
/// alternativo requerido por la especificación del proyecto en caso de fallo.
final class AdviceService: Sendable {
    static let shared = AdviceService()

    /// Mensaje alternativo exacto requerido por AGENTS.md si la API no está disponible.
    static let fallbackAdvice = "Hoy es un buen día para dar un pequeño paso hacia un hogar más organizado."

    private let endpoint = URL(string: "https://api.adviceslip.com/advice")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Consulta de manera asíncrona el consejo del día en línea.
    ///
    /// - Returns: El texto del consejo obtenido o el mensaje de respaldo si ocurre algún error.
    func fetchDailyAdvice() async -> String {
        do {
            var request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.timeoutInterval = 8
            request.cachePolicy = .reloadIgnoringLocalCacheData

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return Self.fallbackAdvice
            }

            let decoded = try JSONDecoder().decode(AdviceResponse.self, from: data)
            let advice = decoded.slip.advice.trimmingCharacters(in: .whitespacesAndNewlines)
            return advice.isEmpty ? Self.fallbackAdvice : advice
        } catch {
            return Self.fallbackAdvice
        }
    }
}

