//
//  User.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String? // Opcional para teens
    var appleId: String
    var accountType: AccountType?
    var avatarURL: URL?
    var addresses: [Address]?
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

