import Foundation
import SwiftData

/// Toda la lógica de hogares e integrantes. Las reglas se validan aquí siempre,
/// aunque la pantalla ya las haya validado. Cada operación que cambia varias filas
/// se guarda con un solo `save()` (si algo falla se hace `rollback()`).
@MainActor
final class HouseholdRepository {
    enum JoinResult: Equatable { case pending }

    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Consultas

    func household(id: String) -> Household? {
        first(FetchDescriptor<Household>(predicate: #Predicate { $0.id == id }))
    }

    func household(code: String) -> Household? {
        first(FetchDescriptor<Household>(predicate: #Predicate { $0.code == code }))
    }

    func member(id: String) -> Member? {
        first(FetchDescriptor<Member>(predicate: #Predicate { $0.id == id }))
    }

    func members(householdId: String) -> [Member] {
        let descriptor = FetchDescriptor<Member>(
            predicate: #Predicate { $0.householdId == householdId },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func approvedMembers(householdId: String) -> [Member] {
        members(householdId: householdId).filter(\.isApproved)
    }

    /// Código aleatorio que todavía no usa ningún hogar.
    func suggestCode() -> String {
        var code = HouseholdCode.random()
        while household(code: code) != nil { code = HouseholdCode.random() }
        return code
    }

    // MARK: - 3.1 Crear hogar

    func createHousehold(name rawName: String, householdName rawHousehold: String, recoveryUser: String, code rawCode: String) throws -> Member {
        let name = rawName.trimmed
        let householdName = rawHousehold.trimmed
        let code = HouseholdCode.normalize(rawCode)
        if name.isEmpty { throw HogarError.emptyName }
        if householdName.isEmpty { throw HogarError.emptyHouseholdName }
        if let error = RecoveryUser.validate(recoveryUser, name: name) { throw error }
        guard HouseholdCode.isValid(code) else { throw HogarError.invalidCode }

        return try transaction {
            if household(code: code) != nil { throw HogarError.codeTaken }
            let household = Household(name: householdName, code: code)
            let member = Member(
                householdId: household.id,
                name: name,
                isAdmin: true,
                isApproved: true,
                recoveryKey: RecoveryUser.hash(recoveryUser)
            )
            context.insert(household)
            context.insert(member)
            return member
        }
    }

    // MARK: - 3.2 Unirse (queda pendiente de aprobación)

    @discardableResult
    func joinHousehold(name rawName: String, recoveryUser: String, code rawCode: String) throws -> JoinResult {
        let name = rawName.trimmed
        let code = HouseholdCode.normalize(rawCode)
        if name.isEmpty { throw HogarError.emptyName }
        if let error = RecoveryUser.validate(recoveryUser, name: name) { throw error }
        guard HouseholdCode.isValid(code) else { throw HogarError.invalidCode }
        guard let household = household(code: code) else { throw HogarError.codeNotFound }

        let nameKey = Member.key(for: name)
        let existing = members(householdId: household.id)
        if existing.contains(where: { $0.nameKey == nameKey }) { throw HogarError.nameTaken }

        return try transaction {
            let member = Member(
                householdId: household.id,
                name: name,
                isApproved: false,
                recoveryKey: RecoveryUser.hash(recoveryUser)
            )
            context.insert(member)

            // Si alguna vez lo eliminaron, ya no debe ver ese aviso.
            for notice in removedNotices(householdId: household.id, nameKey: nameKey) {
                context.delete(notice)
            }
            for admin in existing where admin.isAdmin && admin.isApproved {
                notify(admin, household: household, .joinRequest, arg1: name, arg2: household.name)
            }
            return .pending
        }
    }

    // MARK: - 3.3 Iniciar sesión

    func login(nameOrUser rawText: String, code rawCode: String) throws -> Member {
        let code = HouseholdCode.normalize(rawCode)
        guard HouseholdCode.isValid(code) else { throw HogarError.invalidCode }
        guard let household = household(code: code) else { throw HogarError.codeNotFound }

        let all = members(householdId: household.id)
        let nameKey = Member.key(for: rawText)
        let recoveryKey = RecoveryUser.hash(rawText)
        let found = all.first(where: { $0.nameKey == nameKey })
            ?? all.first(where: { !$0.recoveryKey.isEmpty && $0.recoveryKey == recoveryKey })

        guard let member = found else {
            if !removedNotices(householdId: household.id, nameKey: nameKey).isEmpty {
                throw HogarError.removedFromHousehold
            }
            throw HogarError.memberNotFound
        }
        if !member.isApproved { throw HogarError.pendingApproval }
        return member
    }

    // MARK: - 3.4 Recuperar códigos

    struct RecoveredHome: Identifiable, Equatable {
        let id: String
        let householdName: String
        let memberName: String
        let code: String
        let isAdmin: Bool
    }

    func recoverHomes(recoveryUser: String) -> [RecoveredHome] {
        guard !RecoveryUser.normalize(recoveryUser).isEmpty else { return [] }
        let key = RecoveryUser.hash(recoveryUser)
        let descriptor = FetchDescriptor<Member>(
            predicate: #Predicate { $0.recoveryKey == key && $0.isApproved },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        let found = (try? context.fetch(descriptor)) ?? []
        return found.compactMap { member in
            guard let household = household(id: member.householdId) else { return nil }
            return RecoveredHome(
                id: member.id,
                householdName: household.name,
                memberName: member.name,
                code: household.code,
                isAdmin: member.isAdmin
            )
        }
    }

    // MARK: - 5. Acciones de administrador

    func renameHousehold(actorId: String, householdId: String, newName rawName: String) throws {
        let (_, household) = try requireAdmin(actorId: actorId, householdId: householdId)
        let newName = rawName.trimmed
        if newName.isEmpty { throw HogarError.emptyHouseholdName }
        if newName == household.name { return }

        try transaction {
            let oldName = household.name
            household.name = newName
            for member in approvedMembers(householdId: householdId) where !member.isAdmin {
                notify(member, household: household, .renamed, arg1: oldName, arg2: newName)
            }
        }
    }

    func removeMember(actorId: String, memberId: String) throws {
        guard let target = member(id: memberId) else { throw HogarError.memberNotFound }
        let (admin, household) = try requireAdmin(actorId: actorId, householdId: target.householdId)
        if target.id == admin.id || target.isAdmin { throw HogarError.notAllowed }

        try transaction {
            unassignTasks(of: target)
            if target.isApproved {
                context.insert(HouseholdNotice(
                    householdId: household.id,
                    recipientMemberId: target.id,
                    recipientNameKey: target.nameKey,
                    type: .removed,
                    arg1: household.name
                ))
                for member in approvedMembers(householdId: household.id)
                where !member.isAdmin && member.id != target.id {
                    notify(member, household: household, .memberRemoved, arg1: target.name)
                }
            }
            context.delete(target)
        }
    }

    func acceptRequest(actorId: String, memberId: String) throws {
        guard let target = member(id: memberId) else { throw HogarError.memberNotFound }
        let (_, household) = try requireAdmin(actorId: actorId, householdId: target.householdId)
        guard !target.isApproved else { return }

        try transaction {
            for member in approvedMembers(householdId: household.id) where !member.isAdmin {
                notify(member, household: household, .joined, arg1: target.name)
            }
            target.isApproved = true
        }
    }

    func rejectRequest(actorId: String, memberId: String) throws {
        guard let target = member(id: memberId) else { throw HogarError.memberNotFound }
        _ = try requireAdmin(actorId: actorId, householdId: target.householdId)
        guard !target.isApproved else { return }

        try transaction {
            context.delete(target)
        }
    }

    // MARK: - 6. Salir del hogar

    enum LeaveOutcome: Equatable {
        case left
        case householdDeleted
    }

    /// La sesión del dispositivo se debe cerrar antes de llamar a esto.
    @discardableResult
    func leaveHousehold(memberId: String) throws -> LeaveOutcome {
        guard let me = member(id: memberId) else { throw HogarError.memberNotFound }
        guard let household = household(id: me.householdId) else { throw HogarError.codeNotFound }

        return try transaction {
            if me.isAdmin {
                let successor = approvedMembers(householdId: household.id)
                    .filter { $0.id != me.id }
                    .min { $0.createdAt < $1.createdAt }
                guard let successor else {
                    deleteEverything(of: household)
                    return .householdDeleted
                }
                successor.isAdmin = true
                notify(successor, household: household, .admin, arg1: household.name)
            }

            let remaining = approvedMembers(householdId: household.id).filter { $0.id != me.id }
            unassignTasks(of: me)
            let myName = me.name
            context.delete(me)
            for member in remaining {
                notify(member, household: household, .left, arg1: myName)
            }
            return .left
        }
    }

    // MARK: - 7. Mi nombre y mi usuario de recuperación

    func changeMyName(memberId: String, newName rawName: String) throws {
        guard let me = member(id: memberId) else { throw HogarError.memberNotFound }
        let newName = rawName.trimmed
        if newName.isEmpty { throw HogarError.emptyName }
        if newName == me.name { return }

        let newKey = Member.key(for: newName)
        if members(householdId: me.householdId).contains(where: { $0.id != me.id && $0.nameKey == newKey }) {
            throw HogarError.nameTaken
        }
        if me.hasRecoveryUser && RecoveryUser.hash(newName) == me.recoveryKey {
            throw HogarError.nameSameAsRecoveryUser
        }

        try transaction {
            me.name = newName
            me.nameKey = newKey
        }
    }

    func changeRecoveryUser(memberId: String, current: String, new: String, repeatNew: String) throws {
        guard let me = member(id: memberId) else { throw HogarError.memberNotFound }
        if me.hasRecoveryUser && RecoveryUser.hash(current) != me.recoveryKey {
            throw HogarError.recoveryCurrentWrong
        }
        if let error = RecoveryUser.validate(new, name: me.name) { throw error }
        if RecoveryUser.normalize(new) != RecoveryUser.normalize(repeatNew) { throw HogarError.recoveryMismatch }
        let newKey = RecoveryUser.hash(new)
        if me.hasRecoveryUser && newKey == me.recoveryKey { throw HogarError.recoverySameAsCurrent }

        try transaction {
            me.recoveryKey = newKey
        }
    }

    // MARK: - 8. Entrega de avisos

    func pendingNotices(memberId: String) -> [HouseholdNotice] {
        let removed = NoticeType.removed.rawValue
        let descriptor = FetchDescriptor<HouseholdNotice>(
            predicate: #Predicate { $0.recipientMemberId == memberId && !$0.delivered && $0.type != removed },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// "Claim" atómico: marca el aviso como entregado solo si nadie lo hizo antes.
    /// Devuelve `true` si esta llamada lo reclamó (y por lo tanto debe mostrarlo).
    func claim(noticeId: String) -> Bool {
        guard let notice = first(FetchDescriptor<HouseholdNotice>(predicate: #Predicate { $0.id == noticeId })),
              !notice.delivered else { return false }
        notice.delivered = true
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }

    // MARK: - Ayudantes

    /// Comprueba en la capa de datos que quien actúa existe, es admin, está aprobado
    /// y pertenece al hogar. Esconder botones no basta.
    private func requireAdmin(actorId: String, householdId: String) throws -> (Member, Household) {
        guard let actor = member(id: actorId),
              actor.isAdmin, actor.isApproved,
              actor.householdId == householdId,
              let household = household(id: householdId) else {
            throw HogarError.notAllowed
        }
        return (actor, household)
    }

    private func notify(_ recipient: Member, household: Household, _ type: NoticeType, arg1: String = "", arg2: String = "") {
        context.insert(HouseholdNotice(
            householdId: household.id,
            recipientMemberId: recipient.id,
            recipientNameKey: recipient.nameKey,
            type: type,
            arg1: arg1,
            arg2: arg2
        ))
    }

    private func removedNotices(householdId: String, nameKey: String) -> [HouseholdNotice] {
        let removed = NoticeType.removed.rawValue
        let descriptor = FetchDescriptor<HouseholdNotice>(
            predicate: #Predicate { $0.householdId == householdId && $0.recipientNameKey == nameKey && $0.type == removed }
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    private func unassignTasks(of member: Member) {
        let memberId: String? = member.id
        let descriptor = FetchDescriptor<HouseholdTask>(predicate: #Predicate { $0.assigneeId == memberId })
        for task in (try? context.fetch(descriptor)) ?? [] {
            task.assigneeId = nil
        }
    }

    /// Borra el hogar y todos sus datos (tareas, gastos, metas, mascota, ropero,
    /// facturas, eventos, avisos e integrantes).
    private func deleteEverything(of household: Household) {
        let householdId = household.id
        let tasks = FetchDescriptor<HouseholdTask>(predicate: #Predicate { $0.householdId == householdId })
        let notices = FetchDescriptor<HouseholdNotice>(predicate: #Predicate { $0.householdId == householdId })
        let members = FetchDescriptor<Member>(predicate: #Predicate { $0.householdId == householdId })
        ((try? context.fetch(tasks)) ?? []).forEach(context.delete)
        ((try? context.fetch(notices)) ?? []).forEach(context.delete)
        ((try? context.fetch(members)) ?? []).forEach(context.delete)
        deleteAll(Expense.self, FetchDescriptor<Expense>(predicate: #Predicate { $0.householdId == householdId }))
        deleteAll(SavingsGoal.self, FetchDescriptor<SavingsGoal>(predicate: #Predicate { $0.householdId == householdId }))
        deleteAll(PetState.self, FetchDescriptor<PetState>(predicate: #Predicate { $0.householdId == householdId }))
        deleteAll(WardrobeItem.self, FetchDescriptor<WardrobeItem>(predicate: #Predicate { $0.householdId == householdId }))
        deleteAll(Bill.self, FetchDescriptor<Bill>(predicate: #Predicate { $0.householdId == householdId }))
        deleteAll(CalendarEvent.self, FetchDescriptor<CalendarEvent>(predicate: #Predicate { $0.householdId == householdId }))
        context.delete(household)
    }

    private func deleteAll<T: PersistentModel>(_ type: T.Type, _ descriptor: FetchDescriptor<T>) {
        ((try? context.fetch(descriptor)) ?? []).forEach(context.delete)
    }

    private func transaction<T>(_ work: () throws -> T) throws -> T {
        do {
            let result = try work()
            try context.save()
            return result
        } catch let error as HogarError {
            context.rollback()
            throw error
        } catch {
            context.rollback()
            throw HogarError.unknown
        }
    }

    private func first<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) -> T? {
        var descriptor = descriptor
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
