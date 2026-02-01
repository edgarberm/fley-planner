//
//  MockData.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import Foundation

struct MockData {
    static let shared = MockData()
    
    // MARK: - Users
    
    let pilar = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "Pilar",
        email: "pilar@example.com",
        appleId: "pilar_apple",
        accountType: .adult,
        isPremium: true,
        notificationSettings: .default
    )
    
    let albertoP = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        name: "Alberto P.",
        email: "albertop@example.com",
        appleId: "albertop_apple",
        accountType: .adult,
        isPremium: false,
        notificationSettings: .default
    )
    
    let edgar = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        name: "Edgar",
        email: "edgar@example.com",
        appleId: "edgar_apple",
        accountType: .adult,
        isPremium: true,
        notificationSettings: .default
    )
    
    let david = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
        name: "David",
        email: "david@example.com",
        appleId: "david_apple",
        accountType: .adult,
        isPremium: false,
        notificationSettings: .default
    )
    
    // Teen account
    let albertoTeen = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
        name: "Alberto",
        email: nil,
        appleId: "alberto_apple",
        accountType: .children,
        isPremium: false,
        notificationSettings: .default
    )
    
    // MARK: - Children
    
    var alberto: Child {
        Child(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000101")!,
            name: "Alberto",
            birthDate: Calendar.current.date(from: DateComponents(year: 2013, month: 3, day: 15))!,
            photo: nil,
            custodyConfig: .sharedCustody(
                parents: [pilar.id, albertoP.id],
                schedule: .weekdaysWeekends(
                    weekdayParentIndex: 0, // Pilar entre semana
                    weekendParentIndex: 1  // Alberto P. fines de semana alternos
                )
            ),
            medicalInfo: MedicalInfo(
                bloodType: "A+",
                allergies: ["Polen"],
                medications: [],
                emergencyContacts: [
                    EmergencyContact(
                        id: UUID(),
                        name: "Dr. García",
                        relationship: "Pediatra",
                        phone: "+34 600 123 456",
                        isPrimary: true
                    )
                ]
            )
        )
    }
    
    var alvaro: Child {
        Child(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000102")!,
            name: "Álvaro",
            birthDate: Calendar.current.date(from: DateComponents(year: 2017, month: 7, day: 22))!,
            photo: nil,
            custodyConfig: .sharedCustody(
                parents: [pilar.id, edgar.id],
                schedule: .weekdaysWeekends(
                    weekdayParentIndex: 0, // Pilar entre semana
                    weekendParentIndex: 1  // Edgar fines de semana alternos
                )
            ),
            medicalInfo: MedicalInfo(
                bloodType: "O+",
                allergies: [],
                medications: [],
                emergencyContacts: [
                    EmergencyContact(
                        id: UUID(),
                        name: "Dr. García",
                        relationship: "Pediatra",
                        phone: "+34 600 123 456",
                        isPrimary: true
                    )
                ]
            )
        )
    }
    
    var nico: Child {
        Child(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000103")!,
            name: "Nico",
            birthDate: Calendar.current.date(from: DateComponents(year: 2023, month: 6, day: 10))!,
            photo: nil,
            custodyConfig: .livingTogether(primaryCaregiver: pilar.id),
            medicalInfo: MedicalInfo(
                bloodType: "B+",
                allergies: [],
                medications: [],
                emergencyContacts: [
                    EmergencyContact(
                        id: UUID(),
                        name: "Dra. López",
                        relationship: "Pediatra",
                        phone: "+34 600 789 012",
                        isPrimary: true
                    )
                ]
            )
        )
    }
    
    // MARK: - Family
    
    var family: Family {
        Family(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000201")!,
            name: "Familia de Alberto, Álvaro y Nico",
            createdBy: pilar.id,
            createdAt: Date(timeIntervalSince1970: 1704067200), // 2024-01-01
            accessMembers: [pilar.id, albertoP.id, edgar.id, david.id, albertoTeen.id],
            childrenIds: [alberto.id, alvaro.id, nico.id],
            inviteCode: "0000-0000"
        )
    }
    
    // MARK: - ChildBonds
    
    var childBonds: [ChildBond] {
        [
            // Alberto - Pilar (madre bio)
            ChildBond(
                id: UUID(),
                childId: alberto.id,
                userId: pilar.id,
                role: .admin,
                relationship: .mother,
                permissions: Permissions(
                    canEditCalendar: true,
                    canViewExpenses: true,
                    canAddExpenses: true,
                    canApproveExpenses: true,
                    canViewDocuments: true
                ),
                expenseContribution: 0.5
            ),
            
            // Alberto - Alberto P. (padre bio)
            ChildBond(
                id: UUID(),
                childId: alberto.id,
                userId: albertoP.id,
                role: .admin,
                relationship: .father,
                permissions: Permissions(
                    canEditCalendar: true,
                    canViewExpenses: true,
                    canAddExpenses: true,
                    canApproveExpenses: true,
                    canViewDocuments: true
                ),
                expenseContribution: 0.5
            ),
            
            // Alberto - Edgar (caregiver)
            ChildBond(
                id: UUID(),
                childId: alberto.id,
                userId: edgar.id,
                role: .caregiver,
                relationship: .other("Tío"),
                permissions: Permissions(
                    canEditCalendar: true,
                    canViewExpenses: false,
                    canAddExpenses: false,
                    canApproveExpenses: false,
                    canViewDocuments: false
                ),
                expenseContribution: 0.0
            ),
            
            // Álvaro - Pilar (madre bio)
            ChildBond(
                id: UUID(),
                childId: alvaro.id,
                userId: pilar.id,
                role: .admin,
                relationship: .mother,
                permissions: Permissions(
                    canEditCalendar: true,
                    canViewExpenses: true,
                    canAddExpenses: true,
                    canApproveExpenses: true,
                    canViewDocuments: true
                ),
                expenseContribution: 0.5
            ),
            
            // Álvaro - Edgar (padre bio)
            ChildBond(
                id: UUID(),
                childId: alvaro.id,
                userId: edgar.id,
                role: .admin,
                relationship: .father,
                permissions: Permissions(
                    canEditCalendar: true,
                    canViewExpenses: true,
                    canAddExpenses: true,
                    canApproveExpenses: true,
                    canViewDocuments: true
                ),
                expenseContribution: 0.5
            ),
            
            // Álvaro - Alberto P. (caregiver ocasional)
            ChildBond(
                id: UUID(),
                childId: alvaro.id,
                userId: albertoP.id,
                role: .caregiver,
                relationship: .other("Tío"),
                permissions: Permissions(
                    canEditCalendar: true,
                    canViewExpenses: false,
                    canAddExpenses: false,
                    canApproveExpenses: false,
                    canViewDocuments: false
                ),
                expenseContribution: 0.0
            ),
            
            // Nico - Pilar (madre bio)
            ChildBond(
                id: UUID(),
                childId: nico.id,
                userId: pilar.id,
                role: .admin,
                relationship: .mother,
                permissions: Permissions(
                    canEditCalendar: true,
                    canViewExpenses: true,
                    canAddExpenses: true,
                    canApproveExpenses: true,
                    canViewDocuments: true
                ),
                expenseContribution: 0.5
            ),
            
            // Nico - David (padre bio)
            ChildBond(
                id: UUID(),
                childId: nico.id,
                userId: david.id,
                role: .admin,
                relationship: .father,
                permissions: Permissions(
                    canEditCalendar: true,
                    canViewExpenses: true,
                    canAddExpenses: true,
                    canApproveExpenses: true,
                    canViewDocuments: true
                ),
                expenseContribution: 0.5
            ),
            
            // Nico - Edgar (caregiver)
            ChildBond(
                id: UUID(),
                childId: nico.id,
                userId: edgar.id,
                role: .caregiver,
                relationship: .other("Cuidador"),
                permissions: Permissions(
                    canEditCalendar: true,
                    canViewExpenses: false,
                    canAddExpenses: false,
                    canApproveExpenses: false,
                    canViewDocuments: false
                ),
                expenseContribution: 0.0
            ),
        ]
    }
    
    // MARK: - ChildLinks (for teen Alberto)
    
    var childLinks: [ChildLink] {
        [
            // Alberto teen -> Alberto child (self)
            ChildLink(
                id: UUID(),
                childId: alberto.id,
                userId: albertoTeen.id,
                linkType: .selfChild
            ),
            
            // Alberto teen -> Álvaro (sibling)
            ChildLink(
                id: UUID(),
                childId: alvaro.id,
                userId: albertoTeen.id,
                linkType: .sibling
            ),
            
            // Alberto teen -> Nico (sibling)
            ChildLink(
                id: UUID(),
                childId: nico.id,
                userId: albertoTeen.id,
                linkType: .sibling
            ),
        ]
    }
    
    // MARK: - Events
    
    var events: [CalendarEvent] {
        let now = Date()
        let calendar = Calendar.current
        
        return [
            // Hoy - Recoger a Álvaro del cole
            CalendarEvent(
                id: UUID(),
                childId: alvaro.id,
                creatorId: pilar.id,
                title: "Recoger del colegio",
                startDate: calendar.date(byAdding: .hour, value: 3, to: now)!,
                endDate: calendar.date(byAdding: .hour, value: 4, to: now)!,
                location: "Colegio San José",
                notes: nil,
                type: .pickup,
                assignedCaregiverId: pilar.id,
                visibility: .publicToFamily
            ),
            
            // Mañana - Pediatra Alberto
            CalendarEvent(
                id: UUID(),
                childId: alberto.id,
                creatorId: albertoP.id,
                title: "Pediatra - Revisión anual",
                startDate: calendar.date(byAdding: .day, value: 1, to: now)!,
                endDate: calendar.date(byAdding: DateComponents(day: 1, hour: 1), to: now)!,
                location: "Centro Médico Plaza",
                notes: "Llevar cartilla de vacunación",
                type: .medical,
                assignedCaregiverId: albertoP.id,
                visibility: .publicToFamily
            ),
            
            // Esta semana - Fútbol Alberto
            CalendarEvent(
                id: UUID(),
                childId: alberto.id,
                creatorId: pilar.id,
                title: "Entrenamiento fútbol",
                startDate: calendar.date(byAdding: DateComponents(day: 2, hour: -2), to: now)!,
                endDate: calendar.date(byAdding: DateComponents(day: 2, hour: -1), to: now)!,
                location: "Polideportivo Norte",
                notes: "Llevar uniforme",
                type: .extracurricular,
                assignedCaregiverId: nil, // Lo recoge quien tenga custodia
                visibility: .publicToFamily
            ),
            
            // Edgar se queda a Nico esta tarde (override de custodia)
            CalendarEvent(
                id: UUID(),
                childId: nico.id,
                creatorId: edgar.id,
                title: "Cuidar a Nico",
                startDate: calendar.date(byAdding: .hour, value: 2, to: now)!,
                endDate: calendar.date(byAdding: .hour, value: 6, to: now)!,
                location: "Casa de Edgar",
                notes: "Pilar y David tienen cena",
                type: .other,
                assignedCaregiverId: edgar.id, // Override manual
                visibility: .publicToFamily
            ),
        ]
    }
    
    // MARK: - Expenses
    
    var expenses: [Expense] {
        [
            // Gasto Alberto - Zapatillas
            Expense(
                id: UUID(),
                childId: alberto.id,
                payerId: pilar.id,
                totalAmount: 45.00,
                description: "Zapatillas nuevas",
                date: Date(timeIntervalSinceNow: -86400 * 2), // Hace 2 días
                category: .clothing,
                splits: [
                    ExpenseSplit(
                        id: UUID(),
                        userId: pilar.id,
                        amount: 22.50,
                        isPaid: true,
                        paidDate: Date(timeIntervalSinceNow: -86400 * 2)
                    ),
                    ExpenseSplit(
                        id: UUID(),
                        userId: albertoP.id,
                        amount: 22.50,
                        isPaid: false,
                        paidDate: nil
                    ),
                ]
            ),
            
            // Gasto Álvaro - Extraescolar natación
            Expense(
                id: UUID(),
                childId: alvaro.id,
                payerId: edgar.id,
                totalAmount: 60.00,
                description: "Natación - Mensualidad enero",
                date: Date(timeIntervalSinceNow: -86400 * 5), // Hace 5 días
                category: .extracurricular,
                splits: [
                    ExpenseSplit(
                        id: UUID(),
                        userId: pilar.id,
                        amount: 30.00,
                        isPaid: true,
                        paidDate: Date(timeIntervalSinceNow: -86400 * 3)
                    ),
                    ExpenseSplit(
                        id: UUID(),
                        userId: edgar.id,
                        amount: 30.00,
                        isPaid: true,
                        paidDate: Date(timeIntervalSinceNow: -86400 * 5)
                    ),
                ]
            ),
            
            // Gasto Nico - Pediatra
            Expense(
                id: UUID(),
                childId: nico.id,
                payerId: david.id,
                totalAmount: 80.00,
                description: "Consulta pediatra + vacuna",
                date: Date(timeIntervalSinceNow: -86400 * 7), // Hace 1 semana
                category: .medical,
                splits: [
                    ExpenseSplit(
                        id: UUID(),
                        userId: pilar.id,
                        amount: 40.00,
                        isPaid: false,
                        paidDate: nil
                    ),
                    ExpenseSplit(
                        id: UUID(),
                        userId: david.id,
                        amount: 40.00,
                        isPaid: true,
                        paidDate: Date(timeIntervalSinceNow: -86400 * 7)
                    ),
                ]
            ),
        ]
    }
    
    // MARK: - CareItems
    
    var careItems: [CareItem] {
        let now = Date()
        
        return [
            // Alberto - Llevar uniforme fútbol
            CareItem(
                id: UUID(),
                childId: alberto.id,
                createdBy: pilar.id,
                title: "Llevar uniforme de fútbol",
                notes: "Entrenamiento mañana a las 17:00",
                type: .clothing,
                priority: .normal,
                status: .open,
                visibility: .publicToFamily,
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: now),
                assignedTo: albertoP.id,
                createdAt: now,
                completedAt: nil
            ),
            
            // Álvaro - Firmar autorización
            CareItem(
                id: UUID(),
                childId: alvaro.id,
                createdBy: edgar.id,
                title: "Firmar autorización excursión",
                notes: "Para el viernes. Devolver firmada antes del jueves.",
                type: .school,
                priority: .high,
                status: .open,
                visibility: .publicToFamily,
                dueDate: Calendar.current.date(byAdding: .day, value: 2, to: now),
                assignedTo: pilar.id,
                createdAt: now,
                completedAt: nil
            ),
            
            // Nico - Dar antibiótico
            CareItem(
                id: UUID(),
                childId: nico.id,
                createdBy: pilar.id,
                title: "Dar antibiótico cada 8 horas",
                notes: "Amoxicilina 5ml. Empezó el lunes a las 9:00.",
                type: .medication,
                priority: .urgent,
                status: .inProgress,
                visibility: .publicToFamily,
                dueDate: Calendar.current.date(byAdding: .day, value: 5, to: now),
                assignedTo: nil, // Quien lo tenga
                createdAt: Calendar.current.date(byAdding: .day, value: -2, to: now)!,
                completedAt: nil
            ),
            
            // Alberto - Preparar mochila piscina (completado)
            CareItem(
                id: UUID(),
                childId: alberto.id,
                createdBy: albertoP.id,
                title: "Preparar mochila piscina",
                notes: "Bañador, toalla, gafas, gorro",
                type: .logistics,
                priority: .normal,
                status: .completed,
                visibility: .publicToFamily,
                dueDate: Calendar.current.date(byAdding: .day, value: -1, to: now),
                assignedTo: pilar.id,
                createdAt: Calendar.current.date(byAdding: .day, value: -2, to: now)!,
                completedAt: Calendar.current.date(byAdding: .day, value: -1, to: now)
            ),
        ]
    }
    
    // MARK: - Helper to get all data
    
    var allUsers: [User] {
        [pilar, albertoP, edgar, david, albertoTeen]
    }
    
    var allChildren: [Child] {
        [alberto, alvaro, nico]
    }
}
