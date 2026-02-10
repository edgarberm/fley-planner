//
//  User.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var email: String? // Opcional para teens
    var appleId: String
    var accountType: AccountType?
    var avatarURL: URL?
    var isPremium: Bool
    var contactInfo: ContactInfo? // TODO: add to database
    var notificationSettings: NotificationSettings
    var profileCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case appleId = "apple_id"
        case accountType = "account_type"
        case avatarURL = "avater_url"
        case isPremium = "is_premium"
        case contactInfo = "contact_info"
        case notificationSettings = "notification_settings"
        case profileCompleted = "profile_completed"
    }
}

struct ContactInfo: Identifiable, Codable, Equatable {
    let id: UUID
    var telephone: String
    var addresses: [Address]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case telephone
        case addresses
    }
}
