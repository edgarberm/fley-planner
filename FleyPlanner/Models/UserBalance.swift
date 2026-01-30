//
//  UserBalance.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI

struct UserBalance {
    let owed: Decimal      // Lo que el usuario DEBE a otros
    let owedTo: Decimal    // Lo que otros DEBEN al usuario
    
    /// Balance neto: Positivo = le deben, Negativo = debe
    var net: Decimal {
        owedTo - owed
    }
    
    /// Formateado para UI
    var formattedNet: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        
        let nsDecimal = NSDecimalNumber(decimal: abs(net))
        let formatted = formatter.string(from: nsDecimal) ?? "€0.00"
        
        if net > 0 {
            return "+\(formatted)" // Le deben
        } else if net < 0 {
            return "-\(formatted)" // Debe
        } else {
            return formatted // Equilibrado
        }
    }
    
    var isPositive: Bool {
        net > 0
    }
    
    var isNegative: Bool {
        net < 0
    }
    
    var isBalanced: Bool {
        net == 0
    }
}

/// Extension para formatear balances en UI
extension UserBalance {
    /// Color para mostrar en UI
    var displayColor: Color {
        if isPositive {
            return .green
        } else if isNegative {
            return .red
        } else {
            return .secondary
        }
    }
    
    /// Icono SF Symbol
    var icon: String {
        if isPositive {
            return "arrow.up.circle.fill"
        } else if isNegative {
            return "arrow.down.circle.fill"
        } else {
            return "equal.circle.fill"
        }
    }
    
    /// Descripción para UI
    var description: String {
        if isPositive {
            return "They owe you"
        } else if isNegative {
            return "You owe"
        } else {
            return "Balanced"
        }
    }
}
