//
//  OnboardingState.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import SwiftUI
import Observation

enum OnboardingRoute: Equatable {
    case welcome                 // Tras login Apple
    case familyChoice            // Crear / Unirse / Skip
    case createFamily
    case joinFamily
    case finished                // Entrar al dashboard
}


@Observable
final class OnboardingState {
    var route: OnboardingRoute = .welcome
    
    var name: String = ""
    var accountType: AccountType? = nil
    var familyName: String = ""
    var inviteCode: String = ""
    
    init(appState: AppState) {
        // Usamos el nombre del user ya existente si lo hay
        self.name = appState.currentUser?.name  // Usuario existente
                ?? appState.appleFullName       // Sign in nuevo
                ?? ""
        self.accountType = appState.currentUser?.accountType
    }
    
    var canCreateFamily: Bool {
        familyName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }
    
    var canFinish: Bool {
        // En el futuro aquí puedes validar estado mínimo
        true
    }
    
    func advance(to newRoute: OnboardingRoute) {
        route = newRoute
    }
    
    func reset() {
        name = ""
        accountType = .adult
        route = .welcome
    }
    
    var nameBinding: Binding<String> {
        Binding(
            get: { self.name },
            set: { self.name = $0 }
        )
    }
    
    var accountTypeBinding: Binding<AccountType?> {
        Binding(
            get: { self.accountType },
            set: { self.accountType = $0 }
        )
    }
    
    var familyNameBinding: Binding<String> {
        Binding(
            get: { self.familyName },
            set: { self.familyName = $0 }
        )
    }
    
    var inviteCodeBinding: Binding<String> {
        Binding(
            get: { self.inviteCode },
            set: { self.inviteCode = $0 }
        )
    }
}
