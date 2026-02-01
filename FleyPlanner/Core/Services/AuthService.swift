//
//  AuthService.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import Foundation
import Supabase
import AuthenticationServices

final class AuthService: NSObject {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
        super.init()
    }
}
