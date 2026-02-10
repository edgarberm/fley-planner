//
//  RelationshipType.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

enum RelationshipType: Codable, Hashable {
    case mother, father, stepParent, grandparent, nanny
    case other(String)
    
    var displayName: String {
        switch self {
            case .mother: return "Mother"
            case .father: return "Father"
            case .stepParent: return "Stepparent"
            case .grandparent: return "Grandparent"
            case .nanny: return "Nanny"
            case .other(let custom): return custom.capitalized
        }
    }
    
    var icon: String {
        switch self {
            case .mother: return "figure.dress.line.vertical.figure"
            case .father: return "figure.stand"
            case .stepParent: return "figure.2"
            case .grandparent: return "figure.walk"
            case .nanny: return "person.fill"
            case .other: return "person.circle"
        }
    }
    
    static var allPredefined: [RelationshipType] {
        [.mother, .father, .stepParent, .grandparent, .nanny]
    }
    
    // MARK: - Codable
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
            case "mother": self = .mother
            case "father": self = .father
            case "stepParent": self = .stepParent
            case "grandparent": self = .grandparent
            case "nanny": self = .nanny
            default:
                // Cualquier otro string se trata como .other
                self = .other(rawValue)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
            case .mother: try container.encode("mother")
            case .father: try container.encode("father")
            case .stepParent: try container.encode("stepParent")
            case .grandparent: try container.encode("grandparent")
            case .nanny: try container.encode("nanny")
            case .other(let value): try container.encode(value)
        }
    }
    
    // MARK: - Equatable & Hashable
    
    static func == (lhs: RelationshipType, rhs: RelationshipType) -> Bool {
        switch (lhs, rhs) {
            case (.mother, .mother), (.father, .father), (.stepParent, .stepParent),
                (.grandparent, .grandparent), (.nanny, .nanny):
                return true
            case (.other(let lhsValue), .other(let rhsValue)):
                return lhsValue.lowercased().trimmingCharacters(in: .whitespaces) ==
                rhsValue.lowercased().trimmingCharacters(in: .whitespaces)
            default:
                return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
            case .mother: hasher.combine("mother")
            case .father: hasher.combine("father")
            case .stepParent: hasher.combine("stepParent")
            case .grandparent: hasher.combine("grandparent")
            case .nanny: hasher.combine("nanny")
            case .other(let value):
                hasher.combine("other")
                hasher.combine(value.lowercased().trimmingCharacters(in: .whitespaces))
        }
    }
}
