import Foundation

/// Sesión del dispositivo: solo guarda memberId y householdId de quien la tiene abierta.
struct SessionStore {
    struct Session: Equatable {
        let memberId: String
        let householdId: String
    }

    private let defaults: UserDefaults
    private let memberKey = "session.memberId"
    private let householdKey = "session.householdId"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> Session? {
        guard let memberId = defaults.string(forKey: memberKey),
              let householdId = defaults.string(forKey: householdKey) else { return nil }
        return Session(memberId: memberId, householdId: householdId)
    }

    func save(_ session: Session) {
        defaults.set(session.memberId, forKey: memberKey)
        defaults.set(session.householdId, forKey: householdKey)
    }

    func clear() {
        defaults.removeObject(forKey: memberKey)
        defaults.removeObject(forKey: householdKey)
    }
}
