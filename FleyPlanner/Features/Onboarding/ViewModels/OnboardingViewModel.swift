//
//  OnboardingViewModel.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI
import Observation

@Observable
final class OnboardingViewModel {
    var currentStep: Int = 2 // Empezamos en el 2 post-Auth
    
    // Datos que vamos recolectando
    var userName: String = ""
    var familyName: String = ""
    var children: [Child] = []
    
    // Referencia al servicio para persistir
    private let dataService: DataService
    
    init(dataService: DataService = SupabaseService.shared) {
        self.dataService = dataService
    }
    
    func next() {
        if currentStep < 9 {
            withAnimation { currentStep += 1 }
        }
    }
    
    func back() {
        if currentStep > 2 {
            withAnimation { currentStep -= 1 }
        }
    }
}
