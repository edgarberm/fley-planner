//
//  AppRouter.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 4/2/26.
//

import SwiftUI
import Observation

@Observable
final class AppRouter {
    var showSettings: Bool = false
    
    func openSettings() {
        showSettings = true
    }
    
    func closeSettings() {
        showSettings = false
    }
}
