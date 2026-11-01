import Foundation

/// Textos en español e inglés. Se resuelven en Swift (no con .xcstrings) para que
/// el proyecto compile igual con xtool desde Linux/WSL.
/// En inglés el proyecto usa "home", nunca "household".
enum L10n {
    static var isEnglish: Bool {
        (Locale.preferredLanguages.first ?? "es").hasPrefix("en")
    }

    static func tr(_ es: String, _ en: String) -> String {
        isEnglish ? en : es
    }

    // MARK: Bienvenida
    static var welcomeTitle: String { tr("Bienvenido a HogarGo", "Welcome to HogarGo") }
    static var welcomeSubtitle: String { tr("Organiza tu hogar en equipo, con Zori.", "Run your home as a team, with Zori.") }
    static var createHome: String { tr("Crear un hogar", "Create a Home") }
    static var joinHome: String { tr("Unirme a un hogar", "Join a Home") }
    static var signIn: String { tr("Iniciar Sesión", "Sign In") }
    static var cancel: String { tr("Cancelar", "Cancel") }
    static var close: String { tr("Cerrar", "Close") }
    static var save: String { tr("Guardar", "Save") }
    static var copy: String { tr("Copiar", "Copy") }
    static var copied: String { tr("Código copiado", "Code copied") }

    // MARK: Campos
    static var yourName: String { tr("Tu nombre", "Your name") }
    static var yourNamePlaceholder: String { tr("Ej. Ana", "E.g. Ana") }
    static var homeName: String { tr("Nombre del hogar", "Home name") }
    static var homeNamePlaceholder: String { tr("Ej. Casa Pérez", "E.g. Perez House") }
    static var homeCode: String { tr("Código del hogar", "Home code") }
    static var regenerateCode: String { tr("Generar otro", "Generate another") }
    static var createAction: String { tr("Crear hogar", "Create home") }
    static var joinAction: String { tr("Enviar solicitud", "Send request") }

    static var recoveryLabel: String { tr("Usuario de recuperación", "Recovery username") }
    static var recoveryPlaceholder: String { tr("Ej. familia_perez24", "E.g. perez_family24") }
    static var recoveryHelp: String {
        tr("Es distinto de tu nombre. Con él podrás ver el código de tus hogares si lo olvidas. Guárdalo bien y no lo compartas.",
           "It's different from your name. With it you can see the code of your homes if you forget it. Keep it safe and don't share it.")
    }
    static var recoveryChangeHelp: String {
        tr("Por seguridad escribe tu usuario actual y luego el nuevo dos veces.",
           "For security, type your current username and then the new one twice.")
    }
    static var recoveryCurrent: String { tr("Usuario actual", "Current username") }
    static var recoveryNew: String { tr("Usuario nuevo", "New username") }
    static var recoveryRepeat: String { tr("Repite el usuario nuevo", "Repeat the new username") }

    // MARK: Login y recuperación
    static var loginLabel: String { tr("Tu nombre o usuario", "Your name or username") }
    static var loginPlaceholder: String { tr("Nombre en el hogar o usuario de recuperación", "Name in the home or recovery username") }
    static var forgotCode: String { tr("¿Olvidaste el código?", "Forgot the code?") }
    static var recoverTitle: String { tr("Recuperar código", "Recover code") }
    static var showCodes: String { tr("Ver códigos", "Show codes") }
    static var enter: String { tr("Entrar", "Enter") }
    static var recoverDescription: String {
        tr("Escribe tu usuario de recuperación para ver los códigos de los hogares en los que sigues siendo integrante.",
           "Enter your recovery username to see the codes of the homes you're still a member of.")
    }
    static var recoverEmpty: String {
        tr("No encontramos hogares con ese usuario. Revisa que esté bien escrito.",
           "We couldn't find homes with that username. Check that it's spelled correctly.")
    }
    static func registeredAs(_ name: String) -> String { tr("Te registraste como: \(name)", "You signed up as: \(name)") }

    static var requestSentTitle: String { tr("¡Solicitud enviada!", "Request sent!") }
    static var requestSentBody: String {
        tr("El administrador del hogar debe aceptarte antes de que puedas entrar. Cuando lo haga, usa Iniciar Sesión con tu nombre y el código.",
           "The home admin must accept you before you can get in. Once they do, use Sign In with your name and the code.")
    }

    // MARK: Perfil
    static var profile: String { tr("Perfil", "Profile") }
    static var changeMyName: String { tr("Cambiar mi nombre", "Change my name") }
    static func currentName(_ n: String) -> String { tr("Nombre actual: \(n)", "Current name: \(n)") }
    static var newName: String { tr("Tu nuevo nombre", "Your new name") }
    static var nameOnlyHere: String {
        tr("Solo cambia en este hogar. En tus otros hogares conservas el nombre que tengas allí.",
           "It only changes in this home. In your other homes you keep the name you have there.")
    }
    static var renameHome: String { tr("Cambiar nombre del hogar", "Rename home") }
    static func pendingRequests(_ n: Int) -> String { tr("Solicitudes pendientes (\(n))", "Pending requests (\(n))") }
    static var accept: String { tr("Aceptar", "Accept") }
    static var reject: String { tr("Rechazar", "Reject") }
    static var remove: String { tr("Eliminar", "Remove") }
    static var members: String { tr("Integrantes", "Members") }
    static var adminBadge: String { tr("Admin", "Admin") }
    static var you: String { tr("Tú", "You") }
    static var recoveryConfigured: String { tr("Configurado · toca para cambiarlo", "Set up · tap to change it") }
    static var recoveryNotConfigured: String { tr("Sin configurar · toca para crearlo", "Not set up · tap to create it") }
    static var leaveHome: String { tr("Salir del hogar", "Leave home") }
    static func leaveHomeTitle(_ home: String) -> String { tr("¿Salir de \(home)?", "Leave \(home)?") }
    static var leave: String { tr("Salir", "Leave") }
    static var logout: String { tr("Cerrar sesión", "Sign out") }
    static var nameUpdated: String { tr("Nombre actualizado", "Name updated") }
    static var usernameSaved: String { tr("Usuario guardado", "Username saved") }
    static var homeRenamed: String { tr("Nombre del hogar actualizado", "Home renamed") }

    static func removeTitle(_ name: String) -> String { tr("¿Eliminar a \(name)?", "Remove \(name)?") }
    static var removeBody: String {
        tr("Saldrá del hogar y sus tareas quedarán sin asignar. Podrá volver a pedir ingreso con el código.",
           "They'll leave the home and their tasks will be unassigned. They can request to join again with the code.")
    }

    static var leaveMemberBody: String {
        tr("Dejarás de ser integrante y el código de este hogar ya no aparecerá en tu recuperación. Para volver tendrás que pedir ingreso de nuevo y que el admin te acepte.",
           "You'll stop being a member and this home's code will no longer appear in your recovery. To come back you'll have to request to join again and be accepted by the admin.")
    }
    static var leaveAdminBody: String {
        tr("Eres el admin: al salir, el rol pasará al integrante más antiguo del hogar. Para volver tendrás que pedir ingreso de nuevo.",
           "You're the admin: when you leave, the role will pass to the oldest member of the home. To come back you'll have to request to join again.")
    }
    static var leaveLastBody: String {
        tr("Eres la única persona de este hogar. Si sales, el hogar y todos sus datos (tareas, gastos, calendario y Zori) se eliminarán para siempre.",
           "You're the only person in this home. If you leave, the home and all its data (tasks, expenses, calendar and Zori) will be deleted forever.")
    }

    // MARK: Notificaciones
    static var channelName: String { tr("Novedades del hogar", "Home updates") }
}
