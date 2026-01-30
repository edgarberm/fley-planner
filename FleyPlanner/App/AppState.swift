//
//  AppState.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI
import Observation

@Observable
final class AppState {
    var currentUser: User?
    private(set) var dataService: DataService
    var selectedTab: Tab = .dashboard
    
    enum Tab {
        case dashboard, calendar, expenses, children
    }
    
    init(dataService: DataService = MockDataService.shared) {
        self.dataService = dataService
        print("🟢 AppState initialized")
    }
    
    var isAuthenticated: Bool {
        currentUser != nil
    }
    
    func signIn(userId: UUID) async {
        print("🔵 Signing in user: \(userId)")
        currentUser = await dataService.getUser(id: userId)
        print("🟢 Signed in as: \(currentUser?.name ?? "nil")")
    }
    
    func signOut() {
        print("🔴 Signing out")
        currentUser = nil
    }
}
