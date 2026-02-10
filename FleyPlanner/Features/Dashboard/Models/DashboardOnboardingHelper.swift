//
//  DashboardOnboardingHelper.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 9/2/26.
//

import Foundation

struct DashboardOnboardingHelper {
    let context: DashboardContext
    let user: User
    let family: Family
    
    /// Acciones pendientes que el usuario debería completar
    struct OnboardingAction: Identifiable {
        let id = UUID()
        let type: ActionType
        let priority: Int  // 0 = alta, 1 = media, 2 = baja
        
        enum ActionType {
            case completeProfile      // Avatar, addresses
            case addFirstChild        // No hay niños
            case invitePartner        // Solo 1 adulto en la familia
            case addChildDetails      // Niños sin info médica/custodia
            case setupNotifications   // Notificaciones no configuradas
        }
    }
    
    /// Analiza el estado y devuelve acciones pendientes
    func analyzeOnboardingStatus() -> [OnboardingAction] {
        var actions: [OnboardingAction] = []
        
        // 1. Perfil incompleto
        if !user.profileCompleted || user.avatarURL == nil {
            actions.append(OnboardingAction(type: .completeProfile, priority: 0))
        }
        
        // 2. No hay niños
        if context.activeChildren.isEmpty {
            actions.append(OnboardingAction(type: .addFirstChild, priority: 0))
        }
        
        // 3. Solo hay 1 adulto (el creador)
        if family.accessMembers.count == 1 {
            actions.append(OnboardingAction(type: .invitePartner, priority: 1))
        }
        
        // 4. Hay niños pero sin detalles completos
//        let childrenWithoutDetails = context.activeChildren.filter { summary in
//            summary.child.medicalInfo?.bloodType == nil ||
//            summary.child.medicalInfo?.emergencyContacts.isEmpty
//        }
//        if !childrenWithoutDetails.isEmpty {
//            actions.append(OnboardingAction(type: .addChildDetails, priority: 2))
//        }
        
        // Ordenar por prioridad
        return actions.sorted { $0.priority < $1.priority }
    }
    
    /// Determina si debe mostrar widgets de onboarding
    var shouldShowOnboardingWidgets: Bool {
        !analyzeOnboardingStatus().isEmpty
    }
    
    /// Determina qué widgets específicos mostrar
    func widgetsToShow() -> [DashboardWidgetKind] {
        let actions = analyzeOnboardingStatus()
        var widgets: [DashboardWidgetKind] = []
        
        for action in actions.prefix(3) {  // Máximo 3 widgets de onboarding
            switch action.type {
            case .completeProfile:
                widgets.append(.onboardingCompleteProfile)
            case .addFirstChild:
                widgets.append(.onboardingAddChild)
            case .invitePartner:
                widgets.append(.onboardingInvitePartner)
            case .addChildDetails:
                widgets.append(.onboardingChildDetails)
            case .setupNotifications:
                widgets.append(.onboardingNotifications)
            }
        }
        
        return widgets
    }
}
