//
//  ActivityOverride.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 17/2/26.
//

import Foundation

struct ActivityOverride: Identifiable, Hashable, Codable {
    let id: UUID
    let activityID: UUID
    let familyID: UUID
    
    let date: Date                              // Día afectado (startOfDay)
    
    var overriddenStartTime: TimeComponents?
    var overriddenEndTime: TimeComponents?
    var overriddenSubjects: [MemberID]?
    var overriddenParticipants: [MemberID]?
    
    var cancelled: Bool
    var completionStatus: CompletionStatus?
    
    let createdAt: Date
    let createdBy: MemberID
    
    init(
        id: UUID = UUID(),
        activityID: UUID,
        familyID: UUID,
        date: Date,
        overriddenStartTime: TimeComponents? = nil,
        overriddenEndTime: TimeComponents? = nil,
        overriddenSubjects: [MemberID]? = nil,
        overriddenParticipants: [MemberID]? = nil,
        cancelled: Bool = false,
        completionStatus: CompletionStatus? = nil,
        createdAt: Date = Date(),
        createdBy: MemberID
    ) {
        self.id = id
        self.activityID = activityID
        self.familyID = familyID
        self.date = Calendar.current.startOfDay(for: date)
        self.overriddenStartTime = overriddenStartTime
        self.overriddenEndTime = overriddenEndTime
        self.overriddenSubjects = overriddenSubjects
        self.overriddenParticipants = overriddenParticipants
        self.cancelled = cancelled
        self.completionStatus = completionStatus
        self.createdAt = createdAt
        self.createdBy = createdBy
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case activityID = "activity_id"
        case familyID = "family_id"
        case date
        case overriddenStartTime = "overridden_start_time"
        case overriddenEndTime = "overridden_end_time"
        case overriddenSubjects = "overridden_subjects"
        case overriddenParticipants = "overridden_participants"
        case cancelled
        case completionStatus = "completion_status"
        case createdAt = "created_at"
        case createdBy = "created_by"
    }
}
