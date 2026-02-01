//
//  WidgetFactory.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI

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
            
        // Los widgets de onboarding no deberían llegar aquí
        case .onboardingWelcome, .onboardingAddChild, .onboardingInvitePartner:
            return AnyView(
                Text("Error: Use onboardingView() for onboarding widgets")
                    .foregroundStyle(.red)
            )
        }
    }
    
    /// Renderiza widgets de onboarding
    static func onboardingView(for widget: Widget) -> AnyView {
        guard let metadata = widget.kind.onboardingMetadata else {
            return AnyView(
                Text("No metadata for \(widget.kind.rawValue)")
                    .foregroundStyle(.secondary)
            )
        }
        
        switch widget.kind {
        case .onboardingWelcome:
            // Widget wide especial
            return AnyView(OnboardingWelcomeWidgetView(metadata: metadata))
            
        case .onboardingAddChild, .onboardingInvitePartner:
            // Widgets medium con acción
            return AnyView(
                OnboardingWidgetView(
                    metadata: metadata,
                    action: widget.onboardingAction
                )
            )
            
        default:
            return AnyView(EmptyView())
        }
    }
}
