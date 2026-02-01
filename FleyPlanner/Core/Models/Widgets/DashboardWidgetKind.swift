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
    
    // Widgets de onboarding
    case onboardingWelcome
    case onboardingAddChild
    case onboardingInvitePartner
    
    var isOnboarding: Bool {
        switch self {
        case .onboardingWelcome, .onboardingAddChild, .onboardingInvitePartner:
            return true
        default:
            return false
        }
    }
    
    // Metadatos para widgets de onboarding
    var onboardingMetadata: OnboardingWidgetMetadata? {
        switch self {
        case .onboardingWelcome:
            return OnboardingWidgetMetadata(
                title: "Welcome to FleyPlanner! 👋",
                description: "Let's get started setting up your family. We'll guide you through adding your first child and inviting your co-parent.",
                icon: "hand.wave.fill",
                actionTitle: "Get Started",
                gradientColors: [Color.blue, Color.purple]
            )
        case .onboardingAddChild:
            return OnboardingWidgetMetadata(
                title: "Add Your First Child",
                description: "Start by adding your child's information to manage their schedule and expenses.",
                icon: "person.crop.circle.badge.plus",
                actionTitle: "Add Child",
                gradientColors: [Color.green, Color.mint]
            )
        case .onboardingInvitePartner:
            return OnboardingWidgetMetadata(
                title: "Invite Your Co-Parent",
                description: "Share your family code to collaborate on parenting tasks and expenses.",
                icon: "person.2.fill",
                actionTitle: "Share Code",
                gradientColors: [Color.orange, Color.pink]
            )
        default:
            return nil
        }
    }
}
