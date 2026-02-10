//
//  SupabaseService+Widgets.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 10/2/26.
//

import Foundation
import Supabase

extension SupabaseService {
    // MARK: - Dashboard Widgets
    
    func getWidgetConfigs(for userId: UUID) async throws -> [DashboardWidgetConfig] {
        let response = try await client
            .from("dashboard_widgets")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("position")
            .execute()
        
        let configs = try JSONDecoder().decode([DashboardWidgetConfig].self, from: response.data)
        print("✅ Loaded \(configs.count) widget configs for user")
        return configs
    }
    
    func saveWidgetConfigs(_ configs: [DashboardWidgetConfig]) async throws {
        print("💾 Saving \(configs.count) widget configs...")
        
        // Actualizar updatedAt
        let updatedConfigs = configs.enumerated().map { index, config in
            var updated = config
            updated.position = index
            updated.updatedAt = Date()
            return updated
        }
        
        // Upsert todos
        try await client
            .from("dashboard_widgets")
            .upsert(updatedConfigs)
            .execute()
        
        print("✅ Widget configs saved")
    }
    
    func addWidgetConfig(_ config: DashboardWidgetConfig) async throws {
        try await client
            .from("dashboard_widgets")
            .insert(config)
            .execute()
        
        print("✅ Widget config added: \(config.kind.rawValue)")
    }
    
    func deleteWidgetConfig(id: UUID) async throws {
        try await client
            .from("dashboard_widgets")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
        
        print("✅ Widget config deleted")
    }
}
