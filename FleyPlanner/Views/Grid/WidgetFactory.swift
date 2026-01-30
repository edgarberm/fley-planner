//
//  WidgetFactory.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI

struct WidgetViewFactory {
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
        }
    }
}
