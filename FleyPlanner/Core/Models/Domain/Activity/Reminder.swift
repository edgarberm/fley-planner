//
//  Reminder.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 17/2/26.
//

import Foundation

struct Reminder: Identifiable, Hashable, Codable {
    let id: UUID
    var minutesBefore: Int
    var recipients: [MemberID]
    
    init(
        id: UUID = UUID(),
        minutesBefore: Int,
        recipients: [MemberID]
    ) {
        self.id = id
        self.minutesBefore = minutesBefore
        self.recipients = recipients
    }
    
    var displayName: String {
        switch minutesBefore {
            case 0: return "At time of event"
            case 5: return "5 minutes before"
            case 10: return "10 minutes before"
            case 15: return "15 minutes before"
            case 30: return "30 minutes before"
            case 60: return "1 hour before"
            case 120: return "2 hours before"
            case 1440: return "1 day before"
            default: return "\(minutesBefore) minutes before"
        }
    }
}
