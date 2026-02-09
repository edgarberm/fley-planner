//
//  WidgetFactory.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI

struct WidgetViewFactory {
    /// Renderiza widgets normales con datos del contexto
    static func view(for widget: Widget, context: DashboardContext) -> AnyView {
        switch widget.kind {
            case .balance:
                return AnyView(BalanceWidgetView(balance: context.totalBalance))
            case .miniCalendar:
                return AnyView(Text("Mini Calendar"))
            case .upcomingEvents:
                return AnyView(EventsWidgetView(events: context.upcomingEvents))
            case .pendingExpenses:
                return AnyView(ExpensesWidgetView(expenses: context.pendingExpenses))
            case .todaySummary:
                return AnyView(TodayWidgetView(user: context.currentUser))
            case .childrenStatus:
                return AnyView(ChildrenWidgetView(children: context.activeChildren))
                
                // Los widgets de onboarding no deberían llegar aquí, pero fallback
            case .onboardingCompleteProfile,
                    .onboardingAddChild,
                    .onboardingInvitePartner,
                    .onboardingChildDetails,
                    .onboardingNotifications:
                return AnyView(onboardingView(for: widget.kind))
        }
    }
    
    /// Renderiza widgets de onboarding (solo por kind, sin widget completo)
    static func onboardingView(for kind: DashboardWidgetKind) -> AnyView {
        switch kind {
            case .onboardingCompleteProfile:
                return AnyView(OnboardingCompleteProfileWidget())
            case .onboardingAddChild:
                return AnyView(OnboardingAddChildWidget())
            case .onboardingInvitePartner:
                return AnyView(OnboardingInvitePartnerWidget())
            case .onboardingChildDetails:
                return AnyView(OnboardingChildDetailsWidget())
            case .onboardingNotifications:
                return AnyView(OnboardingNotificationsWidget())
                
                // Normal widgets (no deberían llegar aquí)
            default:
                return AnyView(
                    Text("Error: Use view(for:context:) for normal widgets")
                        .foregroundStyle(.red)
                )
        }
    }
}
