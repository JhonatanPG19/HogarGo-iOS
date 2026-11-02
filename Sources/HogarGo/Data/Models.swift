import Foundation
import SwiftData

/// Hogar. El código se guarda con 6 caracteres sin guion (ej. "HGR789").
@Model
final class Household {
    var id: String
    var name: String
    var code: String
    var createdAt: Int64

    init(id: String = UUID().uuidString, name: String, code: String, createdAt: Int64 = Clock.nowMillis()) {
        self.id = id
        self.name = name
        self.code = code
        self.createdAt = createdAt
    }
}

/// Integrante: uno por persona y por hogar.
@Model
final class Member {
    var id: String
    var householdId: String
    var name: String
    /// `name` en minúsculas. Único por hogar (se valida en el repositorio).
    var nameKey: String
    /// Solo uno por hogar.
    var isAdmin: Bool
    /// `false` = solicitud de ingreso pendiente.
    var isApproved: Bool
    /// SHA-256 del usuario de recuperación normalizado. Vacío = sin configurar.
    var recoveryKey: String
    /// Define quién es "el más antiguo" del hogar.
    var createdAt: Int64

    init(
        id: String = UUID().uuidString,
        householdId: String,
        name: String,
        isAdmin: Bool = false,
        isApproved: Bool = true,
        recoveryKey: String = "",
        createdAt: Int64 = Clock.nowMillis()
    ) {
        self.id = id
        self.householdId = householdId
        self.name = name
        self.nameKey = Member.key(for: name)
        self.isAdmin = isAdmin
        self.isApproved = isApproved
        self.recoveryKey = recoveryKey
        self.createdAt = createdAt
    }

    static func key(for name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    var hasRecoveryUser: Bool { !recoveryKey.isEmpty }
}

/// Aviso por destinatario. Se guarda en la misma transacción que el cambio que lo origina.
@Model
final class HouseholdNotice {
    var id: String
    var householdId: String
    /// Quién debe enterarse.
    var recipientMemberId: String
    /// Permite reconocer a una persona eliminada (ya no existe su `Member`).
    var recipientNameKey: String
    var type: String
    var arg1: String
    var arg2: String
    var createdAt: Int64
    /// `true` cuando ya se mostró la notificación.
    var delivered: Bool

    init(
        householdId: String,
        recipientMemberId: String,
        recipientNameKey: String,
        type: NoticeType,
        arg1: String = "",
        arg2: String = "",
        createdAt: Int64 = Clock.nowMillis()
    ) {
        self.id = UUID().uuidString
        self.householdId = householdId
        self.recipientMemberId = recipientMemberId
        self.recipientNameKey = recipientNameKey
        self.type = type.rawValue
        self.arg1 = arg1
        self.arg2 = arg2
        self.createdAt = createdAt
        self.delivered = false
    }

    var noticeType: NoticeType? { NoticeType(rawValue: type) }
}

/// Tarea del hogar. Por ahora solo guarda lo que necesitan las reglas de integrantes
/// (responsable y hogar); la pantalla de Tareas aún usa datos de ejemplo.
@Model
final class HouseholdTask {
    var id: String
    var householdId: String
    var title: String
    /// Id del integrante responsable. Pasa a `nil` cuando ese integrante sale o es eliminado.
    var assigneeId: String?
    var createdAt: Int64

    init(householdId: String, title: String, assigneeId: String? = nil, createdAt: Int64 = Clock.nowMillis()) {
        self.id = UUID().uuidString
        self.householdId = householdId
        self.title = title
        self.assigneeId = assigneeId
        self.createdAt = createdAt
    }
}

enum NoticeType: String, CaseIterable {
    case renamed = "RENAMED"
    case joinRequest = "JOIN_REQUEST"
    case joined = "JOINED"
    case left = "LEFT"
    case memberRemoved = "MEMBER_REMOVED"
    case admin = "ADMIN"
    /// No es notificación: registro para quien fue eliminado.
    case removed = "REMOVED"
}

enum HogarGoSchema {
    static let models: [any PersistentModel.Type] = [
        Household.self,
        Member.self,
        HouseholdNotice.self,
        HouseholdTask.self,
    ]
}

enum Clock {
    static func nowMillis() -> Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }
}
