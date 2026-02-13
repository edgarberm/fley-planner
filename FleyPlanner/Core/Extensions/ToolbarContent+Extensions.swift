//
//  ToolbarContent+Extensions.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 13/2/26.
//

import SwiftUI

extension ToolbarContent {
    @ToolbarContentBuilder
    func hideSharedBackgroundIfAvailable() -> some ToolbarContent {
        if #available(iOS 26.0, *) {
            sharedBackgroundVisibility(.hidden)
        } else {
            self
        }
    }
}
