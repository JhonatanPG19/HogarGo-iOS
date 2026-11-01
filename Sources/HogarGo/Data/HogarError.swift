import Foundation

/// Catálogo de errores del repositorio.
enum HogarError: String, Error, Equatable {
    case emptyName = "EMPTY_NAME"
    case emptyHouseholdName = "EMPTY_HOUSEHOLD_NAME"
    case invalidCode = "INVALID_CODE"
    case codeNotFound = "CODE_NOT_FOUND"
    case codeTaken = "CODE_TAKEN"
    case nameTaken = "NAME_TAKEN"
    case memberNotFound = "MEMBER_NOT_FOUND"
    case pendingApproval = "PENDING_APPROVAL"
    case recoveryUserInvalid = "RECOVERY_USER_INVALID"
    case recoveryUserSameAsName = "RECOVERY_USER_SAME_AS_NAME"
    case nameSameAsRecoveryUser = "NAME_SAME_AS_RECOVERY_USER"
    case recoveryCurrentWrong = "RECOVERY_CURRENT_WRONG"
    case recoveryMismatch = "RECOVERY_MISMATCH"
    case recoverySameAsCurrent = "RECOVERY_SAME_AS_CURRENT"
    case removedFromHousehold = "REMOVED_FROM_HOUSEHOLD"
    /// Quien actúa no existe, no es admin, no está aprobado o es de otro hogar.
    case notAllowed = "NOT_ALLOWED"
    case unknown = "UNKNOWN"

    /// Campo bajo el que se muestra el error en los formularios.
    enum Field { case name, household, code, recovery, general }

    var field: Field {
        switch self {
        case .invalidCode, .codeNotFound, .codeTaken: return .code
        case .recoveryUserInvalid, .recoveryUserSameAsName, .recoveryCurrentWrong,
             .recoveryMismatch, .recoverySameAsCurrent: return .recovery
        case .emptyHouseholdName: return .household
        case .notAllowed, .unknown: return .general
        default: return .name
        }
    }

    var message: String {
        switch self {
        case .emptyName: return L10n.tr("Escribe tu nombre", "Enter your name")
        case .emptyHouseholdName: return L10n.tr("Escribe el nombre del hogar", "Enter the home name")
        case .invalidCode: return L10n.tr("El código debe tener 6 caracteres", "The code must have 6 characters")
        case .codeNotFound: return L10n.tr("No existe un hogar con ese código", "There's no home with that code")
        case .codeTaken: return L10n.tr("Ese código ya está en uso. Generamos otro.", "That code is already in use. We generated another one.")
        case .nameTaken: return L10n.tr("Ya hay alguien con ese nombre en este hogar", "Someone in this home already has that name")
        case .memberNotFound: return L10n.tr("No encontramos a nadie con ese nombre o usuario en este hogar", "We couldn't find anyone with that name or username in this home")
        case .pendingApproval: return L10n.tr("Tu solicitud aún no ha sido aceptada. Pídele al administrador que te apruebe.", "Your request hasn't been accepted yet. Ask the admin to approve you.")
        case .recoveryUserInvalid: return L10n.tr("Debe tener al menos 4 caracteres", "Must be at least 4 characters")
        case .recoveryUserSameAsName: return L10n.tr("Debe ser distinto de tu nombre", "Must be different from your name")
        case .nameSameAsRecoveryUser: return L10n.tr("Debe ser distinto de tu usuario de recuperación", "Must be different from your recovery username")
        case .recoveryCurrentWrong: return L10n.tr("El usuario actual no coincide", "The current username doesn't match")
        case .recoveryMismatch: return L10n.tr("Los dos usuarios no coinciden", "The two usernames don't match")
        case .recoverySameAsCurrent: return L10n.tr("Debe ser distinto del usuario actual", "Must be different from the current username")
        case .removedFromHousehold: return L10n.tr("El administrador te eliminó de este hogar. Si quieres volver, pide ingreso de nuevo desde «Unirme a un hogar».", "The admin removed you from this home. If you want to come back, request to join again from “Join a Home”.")
        case .notAllowed: return L10n.tr("Solo el administrador puede hacer esto", "Only the admin can do this")
        case .unknown: return L10n.tr("Algo salió mal. Inténtalo de nuevo.", "Something went wrong. Please try again.")
        }
    }
}
