//
//  Activity.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 17/2/26.
//

import Foundation

struct Activity: Identifiable, Hashable, Codable {
    let id: UUID
    let familyID: UUID
    let seriesID: UUID?
    let previousActivityID: UUID?   // Para divisiones de serie
    
    var title: String
    var notes: String?
    
    var subjects: [MemberID]        // Sobre quién es la actividad
    var participants: [MemberID]    // Quién participa/acompaña
    
    var tracksCompletion: Bool
    var recurrence: RecurrenceRule
    var reminders: [Reminder]
    
    let createdAt: Date
    let createdBy: MemberID
    
    init(
        id: UUID = UUID(),
        familyID: UUID,
        seriesID: UUID? = nil,
        previousActivityID: UUID? = nil,
        title: String,
        notes: String? = nil,
        subjects: [MemberID],
        participants: [MemberID],
        tracksCompletion: Bool = false,
        recurrence: RecurrenceRule,
        reminders: [Reminder] = [],
        createdAt: Date = Date(),
        createdBy: MemberID
    ) {
        self.id = id
        self.familyID = familyID
        self.seriesID = seriesID
        self.previousActivityID = previousActivityID
        self.title = title
        self.notes = notes
        self.subjects = subjects
        self.participants = participants
        self.tracksCompletion = tracksCompletion
        self.recurrence = recurrence
        self.reminders = reminders
        self.createdAt = createdAt
        self.createdBy = createdBy
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case familyID = "family_id"
        case seriesID = "series_id"
        case previousActivityID = "previous_activity_id"
        case title
        case notes
        case subjects
        case participants
        case tracksCompletion = "tracks_completion"
        case recurrence
        case reminders
        case createdAt = "created_at"
        case createdBy = "created_by"
    }
}
