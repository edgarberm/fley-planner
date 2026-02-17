//
//  ActivityOccurrence.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 17/2/26.
//

import Foundation

struct ActivityOccurrence: Identifiable {
    var id: String { "\(activityID.uuidString)-\(date.timeIntervalSince1970)" }
    
    let activityID: UUID
    let seriesID: UUID?
    let overrideID: UUID?       // Si viene de un override
    
    let date: Date              // Día (startOfDay)
    let startDate: Date         // Fecha + hora inicio
    let endDate: Date           // Fecha + hora fin
    
    let title: String           // Puede venir de Activity o override
    let notes: String?
    
    let subjects: [MemberID]
    let participants: [MemberID]
    
    let tracksCompletion: Bool
    let completionStatus: CompletionStatus?
    
    let isCancelled: Bool
    let isModified: Bool        // Tiene override pero no cancelada
}
