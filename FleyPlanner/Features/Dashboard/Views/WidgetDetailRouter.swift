//
//  WidgetDetailRouter.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 10/2/26.
//

import SwiftUI

struct WidgetDetailRouter: View {
    let widget: Widget
    
    var body: some View {
        switch widget.kind {
            case .today:
                TodayDetailView()
            case .calendar:
                CalendarDetailView()
            case .children:
                ChildrenDetailView()
        }
    }
}

