//
//  AppModels.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI

// TODO: Add localization
// 1. Add Localizable.strings files
// 2. Support multiple languages

// MARK: - Core Entities

enum AccountType: String, Codable {
    case adult
    case children
    
    var defaultPermissions: Permissions {
        switch self {
        case .adult:
            return Permissions(
                canEditCalendar: true,
                canViewExpenses: true,
                canAddExpenses: true,
                canApproveExpenses: false,
                canViewDocuments: true
            )
        case .children:
            return Permissions(
                canEditCalendar: false,
                canViewExpenses: false,
                canAddExpenses: false,
                canApproveExpenses: false,
                canViewDocuments: false
            )
        }
    }
}

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String? // Opcional para teens
    var appleId: String
    var accountType: AccountType
    var avatarURL: URL?
    var addresses: [Address]
    var isPremium: Bool
    var notificationSettings: NotificationSettings
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case appleId = "apple_id"
        case accountType = "account_type"
        case avatarURL = "avater_url"
        case addresses
        case isPremium = "is_premium"
        case notificationSettings = "notification_settings"
    }
}

struct Family: Identifiable, Codable {
    let id: UUID
    var name: String
    var createdBy: UUID
    var createdAt: Date
    var accessMembers: [UUID] // ✅ Renombrado para claridad
    var childrenIds: [UUID]
    var subscription: FamilySubscription?
    
    struct FamilySubscription: Codable {
        var subscribedUserId: UUID
        var status: SubscriptionStatus
        var startDate: Date
        var expiresAt: Date?
        
        enum SubscriptionStatus: String, Codable {
            case active, cancelled, expired
        }
    }
}

struct Child: Identifiable, Codable {
    let id: UUID
    var name: String
    var birthDate: Date
    var photo: URL?
    var custodyConfig: CustodyConfiguration
    var medicalInfo: MedicalInfo
    
    func whoIsResponsible(at date: Date, events: [CalendarEvent]) -> UUID? {
        let activeEvent = events
            .filter { event in
                event.childId == self.id &&
                event.assignedCaregiverId != nil &&
                date >= event.startDate &&
                date <= event.endDate
            }
            .sorted { $0.startDate > $1.startDate }
            .first
        
        if let manualCaregiver = activeEvent?.assignedCaregiverId {
            return manualCaregiver
        }
        
        return custodyConfig.getResponsibleAt(date: date)
    }
}

struct Address: Codable {
    var label: String?        // "Casa", "Trabajo", "Abuelos"
    var street: String
    var city: String
    var postalCode: String
    var country: String
    var latitude: Double?
    var longitude: Double?
}

/// Vínculo de un TEEN con niños de su familia
/// Los teens NO tienen ChildBonds, solo ChildLinks
struct ChildLink: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let userId: UUID // Debe ser accountType: .teen
    let linkType: LinkType
    
    enum LinkType: String, Codable {
        case selfChild   // El propio teen
        case sibling     // Hermano/a del teen
    }
}

/// Relación entre un ADULTO y un niño
/// Define: rol, permisos, contribución financiera
struct ChildBond: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let userId: UUID // Debe ser accountType: .adult
    var role: Role
    var relationship: RelationshipType
    var permissions: Permissions
    
    var expenseContribution: Decimal {
        didSet {
            expenseContribution = max(0, min(1, expenseContribution))
        }
    }
}

// MARK: - Custody

enum CustodyConfiguration: Codable {
    case livingTogether(primaryCaregiver: UUID?)
    case sharedCustody(parents: [UUID], schedule: CustodySchedule)
    case singleParent(parent: UUID)
    
    func getResponsibleAt(date: Date) -> UUID? {
        switch self {
        case .livingTogether(let primary):
            return primary
        case .sharedCustody(let parents, let schedule):
            return schedule.getResponsibleAt(date: date, parents: parents)
        case .singleParent(let parent):
            return parent
        }
    }
}

enum CustodySchedule: Codable {
    case weeklyAlternating(startsWithIndex: Int, startDate: Date)
    case biweekly(pattern: BiweeklyPattern)
    case weekdaysWeekends(weekdayParentIndex: Int, weekendParentIndex: Int)
    case custom(assignments: [DayAssignment])
    
    struct BiweeklyPattern: Codable {
        let parent1Index: Int
        let parent2Index: Int
        let parent1Days: Int
        let parent2Days: Int
        let parent1WeekendDays: Int
        let startDate: Date
    }
    
    struct DayAssignment: Codable {
        let date: Date
        let parentIndex: Int
    }
    
    func getResponsibleAt(date: Date, parents: [UUID]) -> UUID? {
        guard !parents.isEmpty else { return nil }
        
        switch self {
        case .weeklyAlternating(let startIndex, let startDate):
            guard parents.indices.contains(startIndex) else { return nil }
            
            let weeksSinceStart = Calendar.current.dateComponents(
                [.weekOfYear],
                from: startDate,
                to: date
            ).weekOfYear ?? 0
            
            let currentParentIndex = (startIndex + weeksSinceStart) % parents.count
            return parents[currentParentIndex]
            
        case .biweekly(let pattern):
            return calculateBiweeklyPattern(date: date, pattern: pattern, parents: parents)
            
        case .weekdaysWeekends(let weekdayIndex, let weekendIndex):
            let isWeekend = Calendar.current.isDateInWeekend(date)
            let index = isWeekend ? weekendIndex : weekdayIndex
            guard parents.indices.contains(index) else { return nil }
            return parents[index]
            
        case .custom(let assignments):
            guard let assignment = assignments.first(where: {
                Calendar.current.isDate($0.date, inSameDayAs: date)
            }) else { return nil }
            guard parents.indices.contains(assignment.parentIndex) else { return nil }
            return parents[assignment.parentIndex]
        }
    }
    
    private func calculateBiweeklyPattern(
        date: Date,
        pattern: BiweeklyPattern,
        parents: [UUID]
    ) -> UUID? {
        let daysSinceStart = Calendar.current.dateComponents(
            [.day],
            from: pattern.startDate,
            to: date
        ).day ?? 0
        
        let cycleLength = pattern.parent1Days + pattern.parent2Days + pattern.parent1WeekendDays
        let dayInCycle = daysSinceStart % cycleLength
        
        let index: Int
        if dayInCycle < pattern.parent1Days {
            index = pattern.parent1Index
        } else if dayInCycle < (pattern.parent1Days + pattern.parent2Days) {
            index = pattern.parent2Index
        } else {
            index = pattern.parent1Index
        }
        
        guard parents.indices.contains(index) else { return nil }
        return parents[index]
    }
}

// MARK: - Events & Calendar

struct CalendarEvent: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let creatorId: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var notes: String?
    var type: EventType
    var assignedCaregiverId: UUID?
    var visibility: VisibilityScope
    
    enum EventType: String, Codable, CaseIterable {
        case pickup = "Recogida"
        case dropoff = "Entrega"
        case medical = "Médico"
        case school = "Colegio"
        case extracurricular = "Extraescolar"
        case other = "Otro"
        
        var icon: String {
            switch self {
            case .pickup: return "figure.walk.arrival"
            case .dropoff: return "figure.walk.departure"
            case .medical: return "cross.case"
            case .school: return "book"
            case .extracurricular: return "sportscourt"
            case .other: return "calendar"
            }
        }
    }
}

// MARK: - Care Items (Tasks/Recordatorios)

struct CareItem: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let createdBy: UUID
    var title: String
    var notes: String?
    var type: CareItemType
    var priority: Priority
    var status: CareItemStatus
    var visibility: VisibilityScope
    var dueDate: Date?
    var assignedTo: UUID?
    var createdAt: Date
    var completedAt: Date?
}

enum CareItemType: String, Codable, CaseIterable {
    case clothing = "Ropa/Uniforme"
    case medication = "Medicación"
    case school = "Colegio"
    case food = "Comida"
    case logistics = "Logística"
    case health = "Salud"
    case other = "Otro"
    
    var icon: String {
        switch self {
        case .clothing: return "tshirt"
        case .medication: return "pills"
        case .school: return "book"
        case .food: return "fork.knife"
        case .logistics: return "backpack"
        case .health: return "heart"
        case .other: return "checklist"
        }
    }
}

enum CareItemStatus: String, Codable {
    case open = "Pendiente"
    case inProgress = "En progreso"
    case completed = "Completado"
    case blocked = "Bloqueado"
}

enum Priority: String, Codable {
    case low = "Baja"
    case normal = "Normal"
    case high = "Alta"
    case urgent = "Urgente"
    
    var color: String {
        switch self {
        case .low: return "gray"
        case .normal: return "blue"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
}

// MARK: - Expenses

struct Expense: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let payerId: UUID
    let totalAmount: Decimal
    let description: String
    let date: Date
    let category: ExpenseCategory
    var splits: [ExpenseSplit]
    
    var status: ExpenseStatus {
        if splits.allSatisfy(\.isPaid) {
            return .settled
        } else if splits.contains(where: \.isPaid) {
            return .partiallySettled
        } else {
            return .pending
        }
    }
    
    enum ExpenseCategory: String, Codable, CaseIterable {
        case medical = "Médico"
        case education = "Colegio"
        case clothing = "Ropa"
        case extracurricular = "Extraescolar"
        case food = "Comida"
        case other = "Otro"
    }
    
    static func create(
        childId: UUID,
        payerId: UUID,
        amount: Decimal,
        description: String,
        category: ExpenseCategory = .other,
        bonds: [ChildBond]
    ) -> Expense {
        let responsibleBonds = bonds.filter {
            $0.childId == childId && $0.expenseContribution > 0
        }
        
        let splits = responsibleBonds.map { bond in
            ExpenseSplit(
                id: UUID(),
                userId: bond.userId,
                amount: amount * bond.expenseContribution,
                isPaid: bond.userId == payerId,
                paidDate: bond.userId == payerId ? Date() : nil
            )
        }
        
        return Expense(
            id: UUID(),
            childId: childId,
            payerId: payerId,
            totalAmount: amount,
            description: description,
            date: Date(),
            category: category,
            splits: splits
        )
    }
}

struct ExpenseSplit: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var amount: Decimal
    var isPaid: Bool
    var paidDate: Date?
}

enum ExpenseStatus: String, Codable {
    case pending, partiallySettled, settled
}

// MARK: - Documents

struct Document: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let uploaderId: UUID
    var title: String
    var category: DocumentCategory
    var fileURL: URL
    var thumbnailURL: URL?
    var uploadDate: Date
    var expirationDate: Date?
    
    enum DocumentCategory: String, Codable, CaseIterable {
        case identification = "Identificación"
        case medical = "Médico"
        case school = "Colegio"
        case insurance = "Seguro"
        case legal = "Legal"
        case other = "Otro"
    }
}

// MARK: - Supporting Types

struct MedicalInfo: Codable {
    var bloodType: String?
    var allergies: [String]
    var medications: [String]
    var emergencyContacts: [EmergencyContact]
}

struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    var name: String
    var relationship: String
    var phone: String
    var isPrimary: Bool
}

enum Role: String, Codable {
    case admin
    case collaborator
    case caregiver
}


enum RelationshipType: Codable, Hashable {
    case mother, father, stepParent, grandparent, nanny
    case other(String)
    
    var displayName: String {
        switch self {
        case .mother: return "Mother"
        case .father: return "Father"
        case .stepParent: return "Stepparent"
        case .grandparent: return "Grandparent"
        case .nanny: return "Nanny"
        case .other(let custom): return custom.capitalized
        }
    }
    
    var icon: String {
        switch self {
        case .mother: return "figure.dress.line.vertical.figure"
        case .father: return "figure.stand"
        case .stepParent: return "figure.2"
        case .grandparent: return "figure.walk"
        case .nanny: return "person.fill"
        case .other: return "person.circle"
        }
    }
    
    static var allPredefined: [RelationshipType] {
        [.mother, .father, .stepParent, .grandparent, .nanny]
    }
    
    static func == (lhs: RelationshipType, rhs: RelationshipType) -> Bool {
        switch (lhs, rhs) {
        case (.mother, .mother), (.father, .father), (.stepParent, .stepParent),
             (.grandparent, .grandparent), (.nanny, .nanny):
            return true
        case (.other(let lhsValue), .other(let rhsValue)):
            return lhsValue.lowercased().trimmingCharacters(in: .whitespaces) ==
                   rhsValue.lowercased().trimmingCharacters(in: .whitespaces)
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .mother: hasher.combine("mother")
        case .father: hasher.combine("father")
        case .stepParent: hasher.combine("stepParent")
        case .grandparent: hasher.combine("grandparent")
        case .nanny: hasher.combine("nanny")
        case .other(let value):
            hasher.combine("other")
            hasher.combine(value.lowercased().trimmingCharacters(in: .whitespaces))
        }
    }
}

struct Permissions: Codable {
    var canEditCalendar: Bool
    var canViewExpenses: Bool
    var canAddExpenses: Bool
    var canApproveExpenses: Bool
    var canViewDocuments: Bool
}

enum VisibilityScope: String, Codable {
    case publicToFamily, adminsOnly
}

/// ✅ CORREGIDO: Sin userId redundante
struct NotificationSettings: Codable {
    var enablePushNotifications: Bool
    var enableEmailNotifications: Bool
    var notifyOnNewEvent: Bool
    var notifyOnEventReminder: Bool
    var notifyOnExpenseAdded: Bool
    var notifyOnExpenseApproved: Bool
    var notifyOnCustodyChange: Bool
    var notifyOnDocumentAdded: Bool
    var quietHoursStart: Date?
    var quietHoursEnd: Date?

    // Red de seguridad: Si falta alguna clave en el JSON, usa el valor de 'default'
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let def = NotificationSettings.default
        
        enablePushNotifications = try container.decodeIfPresent(Bool.self, forKey: .enablePushNotifications) ?? def.enablePushNotifications
        enableEmailNotifications = try container.decodeIfPresent(Bool.self, forKey: .enableEmailNotifications) ?? def.enableEmailNotifications
        notifyOnNewEvent = try container.decodeIfPresent(Bool.self, forKey: .notifyOnNewEvent) ?? def.notifyOnNewEvent
        notifyOnEventReminder = try container.decodeIfPresent(Bool.self, forKey: .notifyOnEventReminder) ?? def.notifyOnEventReminder
        notifyOnExpenseAdded = try container.decodeIfPresent(Bool.self, forKey: .notifyOnExpenseAdded) ?? def.notifyOnExpenseAdded
        notifyOnExpenseApproved = try container.decodeIfPresent(Bool.self, forKey: .notifyOnExpenseApproved) ?? def.notifyOnExpenseApproved
        notifyOnCustodyChange = try container.decodeIfPresent(Bool.self, forKey: .notifyOnCustodyChange) ?? def.notifyOnCustodyChange
        notifyOnDocumentAdded = try container.decodeIfPresent(Bool.self, forKey: .notifyOnDocumentAdded) ?? def.notifyOnDocumentAdded
        quietHoursStart = try container.decodeIfPresent(Date.self, forKey: .quietHoursStart)
        quietHoursEnd = try container.decodeIfPresent(Date.self, forKey: .quietHoursEnd)
    }
    
    // Necesitamos esto para que el compilador no se queje al crear uno normal
    init(enablePushNotifications: Bool, enableEmailNotifications: Bool, notifyOnNewEvent: Bool, notifyOnEventReminder: Bool, notifyOnExpenseAdded: Bool, notifyOnExpenseApproved: Bool, notifyOnCustodyChange: Bool, notifyOnDocumentAdded: Bool, quietHoursStart: Date?, quietHoursEnd: Date?) {
        self.enablePushNotifications = enablePushNotifications
        self.enableEmailNotifications = enableEmailNotifications
        self.notifyOnNewEvent = notifyOnNewEvent
        self.notifyOnEventReminder = notifyOnEventReminder
        self.notifyOnExpenseAdded = notifyOnExpenseAdded
        self.notifyOnExpenseApproved = notifyOnExpenseApproved
        self.notifyOnCustodyChange = notifyOnCustodyChange
        self.notifyOnDocumentAdded = notifyOnDocumentAdded
        self.quietHoursStart = quietHoursStart
        self.quietHoursEnd = quietHoursEnd
    }

    static var `default`: NotificationSettings {
        NotificationSettings(
            enablePushNotifications: true, enableEmailNotifications: false,
            notifyOnNewEvent: true, notifyOnEventReminder: true,
            notifyOnExpenseAdded: true, notifyOnExpenseApproved: true,
            notifyOnCustodyChange: true, notifyOnDocumentAdded: true,
            quietHoursStart: nil, quietHoursEnd: nil
        )
    }
}

// MARK: - Widget Models

struct WidgetChildrenToday: Codable {
    let children: [WidgetChild]
    let lastUpdate: Date
    
    struct WidgetChild: Codable {
        let name: String
        let photoURL: String?
        let isWithMe: Bool
        let until: Date?
        let nextEvent: String?
    }
}

struct WidgetBalance: Codable {
    let totalOwed: Double
    let totalOwedTo: Double
    let pendingCount: Int
    let lastUpdate: Date
    
    static func from(balance: UserBalance, pendingCount: Int) -> WidgetBalance {
        WidgetBalance(
            totalOwed: NSDecimalNumber(decimal: balance.owed).doubleValue,
            totalOwedTo: NSDecimalNumber(decimal: balance.owedTo).doubleValue,
            pendingCount: pendingCount,
            lastUpdate: Date()
        )
    }
}

struct WidgetUpcomingEvents: Codable {
    let events: [WidgetEvent]
    let lastUpdate: Date
    
    struct WidgetEvent: Codable {
        let childName: String
        let title: String
        let date: Date
        let assignedTo: String?
    }
}

// Codable → persistencia futura (Supabase / local)
// RawValue → fácil debug + storage
// CaseIterable → menú “Añadir widget” más adelante
enum DashboardWidgetKind: String, Codable, CaseIterable {
    case miniCalendar
    case todaySummary
    case balance
    case upcomingEvents
    case pendingExpenses
    case childrenStatus
}

// MARK: - Decimal Codable Extension

//extension Decimal: Codable {
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        let stringValue = try container.decode(String.self)
//        // "en_US_POSIX" asegura que el intercambio de datos sea siempre independiente de la región del usuario
//        guard let decimal = Decimal(string: stringValue, locale: Locale(identifier: "en_US_POSIX")) else {
//            throw DecodingError.dataCorruptedError(
//                in: container,
//                debugDescription: "Invalid Decimal string: \(stringValue)"
//            )
//        }
//        self = decimal
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        let stringValue = NSDecimalNumber(decimal: self).stringValue
//        try container.encode(stringValue)
//    }
//}

// MARK: - Errors

enum DataError: Error, LocalizedError {
    case userNotFound
    case familyNotFound
    case unauthorized
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "No hemos podido encontrar tu perfil de usuario."
        case .familyNotFound:
            return "No pareces estar vinculado a ninguna familia aún."
        case .unauthorized:
            return "No tienes permiso para realizar esta acción."
        case .networkError(let error):
            return "Error de conexión: \(error.localizedDescription)"
        }
    }
}
