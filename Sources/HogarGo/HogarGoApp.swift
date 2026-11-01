import SwiftData
import SwiftUI

@main
struct HogarGoApp: App {
    private let container: ModelContainer
    @State private var appState: AppState

    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: Schema(HogarGoSchema.models))
        } catch {
            fatalError("No se pudo abrir la base de datos local: \(error)")
        }
        // Las operaciones del repositorio guardan explícitamente (una transacción por acción).
        container.mainContext.autosaveEnabled = false
        self.container = container
        _appState = State(initialValue: AppState(context: container.mainContext))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
        }
        .modelContainer(container)
    }
}
