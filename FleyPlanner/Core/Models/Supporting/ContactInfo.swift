//
//  ContactInfo.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 12/2/26.
//

import Foundation

struct ContactInfo: Codable, Equatable {
    var phones: [PhoneEntry]
    var addresses: [AddressEntry]
    
    init(phones: [PhoneEntry] = [], addresses: [AddressEntry] = []) {
        self.phones = phones
        self.addresses = addresses
    }
}

struct PhoneEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var label: PhoneLabel
    var number: String
    var isPrimary: Bool
    
    init(id: UUID = UUID(), label: PhoneLabel = .mobile, number: String, isPrimary: Bool = false) {
        self.id = id
        self.label = label
        self.number = number
        self.isPrimary = isPrimary
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case label
        case number
        case isPrimary = "is_primary"
    }
}

enum PhoneLabel: String, Codable, CaseIterable {
    case mobile = "mobile"
    case home = "home"
    case work = "work"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .mobile: return "Mobile"
        case .home: return "Home"
        case .work: return "Work"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .mobile: return "iphone"
        case .home: return "house"
        case .work: return "briefcase"
        case .other: return "phone"
        }
    }
}

struct AddressEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var label: AddressLabel
    var street: String
    var city: String
    var state: String?
    var postalCode: String
    var country: String
    var isPrimary: Bool
    
    init(
        id: UUID = UUID(),
        label: AddressLabel = .home,
        street: String,
        city: String,
        state: String? = nil,
        postalCode: String,
        country: String,
        isPrimary: Bool = false
    ) {
        self.id = id
        self.label = label
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
        self.isPrimary = isPrimary
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case label
        case street
        case city
        case state
        case postalCode = "postal_code"
        case country
        case isPrimary = "is_primary"
    }
    
    var formattedAddress: String {
        var parts = [street, city]
        if let state = state { parts.append(state) }
        parts.append(postalCode)
        parts.append(country)
        return parts.joined(separator: ", ")
    }
}

enum AddressLabel: String, Codable, CaseIterable {
    case home = "home"
    case work = "work"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .home: return "Home"
        case .work: return "Work"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .work: return "briefcase"
        case .other: return "mappin"
        }
    }
}


// MARK: - helpers

extension ContactInfo {
    var primaryPhone: PhoneEntry? {
        phones.first { $0.isPrimary } ?? phones.first
    }
    
    var primaryAddress: AddressEntry? {
        addresses.first { $0.isPrimary } ?? addresses.first
    }
    
    var isEmpty: Bool {
        phones.isEmpty && addresses.isEmpty
    }
}
