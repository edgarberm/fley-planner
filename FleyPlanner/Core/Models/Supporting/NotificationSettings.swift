//
//  NotificationSettings.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct NotificationSettings: Codable, Equatable {
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
