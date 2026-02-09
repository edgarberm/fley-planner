//
//  DashboardWidgetKind.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import SwiftUI

enum DashboardWidgetKind: String, Codable, CaseIterable {
    // Widgets normales
    case miniCalendar
    case todaySummary
    case balance
    case upcomingEvents
    case pendingExpenses
    case childrenStatus
    
    // ✨ NUEVOS: Widgets de onboarding
    case onboardingCompleteProfile
    case onboardingAddChild
    case onboardingInvitePartner
    case onboardingChildDetails
    case onboardingNotifications
    
    var defaultSize: WidgetSize {
        switch self {
            case .todaySummary, .upcomingEvents, .pendingExpenses, .onboardingCompleteProfile:
                return .wide
            case .miniCalendar, .balance, .childrenStatus,
                    .onboardingAddChild,
                    .onboardingInvitePartner, .onboardingChildDetails,
                    .onboardingNotifications:
                return .medium
        }
    }
    
    var isOnboarding: Bool {
        switch self {
            case .onboardingCompleteProfile,
                    .onboardingAddChild,
                    .onboardingInvitePartner,
                    .onboardingChildDetails,
                    .onboardingNotifications:
                return true
            default:
                return false
        }
    }
}
