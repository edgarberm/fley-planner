//
//  Family.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct Family: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var createdBy: UUID
    var createdAt: Date
    var accessMembers: [UUID]
    var childrenIds: [UUID]
    
    // columnas planas
    var subscriptionUserId: UUID?
    var subscriptionStatus: FamilySubscription.SubscriptionStatus?
    var subscriptionStartDate: Date?
    var subscriptionExpiresAt: Date?
    
    var inviteCode: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case createdBy = "created_by"
        case createdAt = "created_at"
        case accessMembers = "access_members"
        case childrenIds = "children_ids"
        case subscriptionUserId = "subscription_user_id"
        case subscriptionStatus = "subscription_status"
        case subscriptionStartDate = "subscription_start_date"
        case subscriptionExpiresAt = "subscription_expires_at"
        case inviteCode = "invite_code"
    }
    
    struct FamilySubscription {
        enum SubscriptionStatus: String, Codable {
            case active, cancelled, expired
        }
    }
}


struct CreateFamilyPayload: Encodable {
    let id: UUID
    let name: String
    let createdBy: UUID
    let accessMembers: [UUID]
    let inviteCode: String
    
    // Suscripción (columnas planas)
    let subscriptionUserId: UUID?
    let subscriptionStatus: Family.FamilySubscription.SubscriptionStatus?
    let subscriptionStartDate: Date?
    let subscriptionExpiresAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdBy = "created_by"
        case accessMembers = "access_members"
        case inviteCode = "invite_code"
        case subscriptionUserId = "subscription_user_id"
        case subscriptionStatus = "subscription_status"
        case subscriptionStartDate = "subscription_start_date"
        case subscriptionExpiresAt = "subscription_expires_at"
    }
}
