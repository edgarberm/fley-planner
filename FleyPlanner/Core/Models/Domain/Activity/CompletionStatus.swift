//
//  CompletionStatus.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 17/2/26.
//

import Foundation

enum CompletionStatus: Hashable, Codable {
    case pending
    case completed(at: Date, by: MemberID)
    case skipped(reason: String?)
    
    enum CodingKeys: String, CodingKey {
        case type
        case completedAt = "completed_at"
        case completedBy = "completed_by"
        case skipReason = "skip_reason"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
            case .pending:
                try container.encode("pending", forKey: .type)
            case .completed(let at, let by):
                try container.encode("completed", forKey: .type)
                try container.encode(at, forKey: .completedAt)
                try container.encode(by, forKey: .completedBy)
            case .skipped(let reason):
                try container.encode("skipped", forKey: .type)
                try container.encodeIfPresent(reason, forKey: .skipReason)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
            case "pending":
                self = .pending
            case "completed":
                let at = try container.decode(Date.self, forKey: .completedAt)
                let by = try container.decode(MemberID.self, forKey: .completedBy)
                self = .completed(at: at, by: by)
            case "skipped":
                let reason = try container.decodeIfPresent(String.self, forKey: .skipReason)
                self = .skipped(reason: reason)
            default:
                self = .pending
        }
    }
}
