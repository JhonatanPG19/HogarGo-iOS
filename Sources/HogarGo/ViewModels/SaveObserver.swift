import Foundation
import SwiftData

/// Avisa (en el hilo principal) cada vez que el `ModelContext` termina de guardar.
///
/// Los ViewModels lo usan para volver a leer sus datos aunque el cambio venga de otra pantalla
/// (por ejemplo, completar una tarea cambia las monedas de Zori y los puntos del calendario).
/// Al liberarse, se desuscribe solo.
final class SaveObserver: @unchecked Sendable {
    private var token: NSObjectProtocol?

    init(context: ModelContext, onSave: @escaping @MainActor () -> Void) {
        token = NotificationCenter.default.addObserver(
            forName: ModelContext.didSave, object: context, queue: .main
        ) { _ in
            MainActor.assumeIsolated { onSave() }
        }
    }

    deinit {
        if let token { NotificationCenter.default.removeObserver(token) }
    }
}
