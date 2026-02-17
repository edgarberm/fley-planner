//
//  RecurrenceRule.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 17/2/26.
//

import Foundation

struct RecurrenceRule: Hashable, Codable {
    var frequency: Frequency
    var interval: Int               // Cada N periodos (1 = cada semana, 2 = cada 2 semanas)
    var weekdays: Set<Weekday>?     // Solo para .weekly
    var monthlyDay: Int?            // Solo para .monthly (día del mes)
    var monthlyByDay: MonthlyByDay? // Solo para .monthlyByDay
    var startDate: Date
    var end: RecurrenceEnd
    var startTime: TimeComponents
    var endTime: TimeComponents
    
    init(
        frequency: Frequency,
        interval: Int = 1,
        weekdays: Set<Weekday>? = nil,
        monthlyDay: Int? = nil,
        monthlyByDay: MonthlyByDay? = nil,
        startDate: Date,
        end: RecurrenceEnd = .never,
        startTime: TimeComponents,
        endTime: TimeComponents
    ) {
        self.frequency = frequency
        self.interval = interval
        self.weekdays = weekdays
        self.monthlyDay = monthlyDay
        self.monthlyByDay = monthlyByDay
        self.startDate = startDate
        self.end = end
        self.startTime = startTime
        self.endTime = endTime
    }
    
    enum CodingKeys: String, CodingKey {
        case frequency
        case interval
        case weekdays
        case monthlyDay = "monthly_day"
        case monthlyByDay = "monthly_by_day"
        case startDate = "start_date"
        case end
        case startTime = "start_time"
        case endTime = "end_time"
    }
}

// MARK: - Supporting Types

enum Frequency: String, Hashable, Codable, CaseIterable {
    case daily
    case weekly
    case workingDays
    case weekend
    case monthly
    case monthlyByDay
    
    var displayName: String {
        switch self {
            case .daily: return "Daily"
            case .weekly: return "Weekly"
            case .workingDays: return "Working Days"
            case .weekend: return "Weekends"
            case .monthly: return "Monthly"
            case .monthlyByDay: return "Monthly by Day"
        }
    }
}

enum Weekday: Int, Hashable, Codable, CaseIterable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var displayName: String {
        switch self {
            case .monday: return "Monday"
            case .tuesday: return "Tuesday"
            case .wednesday: return "Wednesday"
            case .thursday: return "Thursday"
            case .friday: return "Friday"
            case .saturday: return "Saturday"
            case .sunday: return "Sunday"
        }
    }
    
    var shortName: String {
        String(displayName.prefix(3))
    }
}

enum RecurrenceEnd: Hashable, Codable {
    case never
    case onDate(Date)
    case afterOccurrences(Int)
    
    enum CodingKeys: String, CodingKey {
        case type
        case date
        case count
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
            case .never:
                try container.encode("never", forKey: .type)
            case .onDate(let date):
                try container.encode("onDate", forKey: .type)
                try container.encode(date, forKey: .date)
            case .afterOccurrences(let count):
                try container.encode("afterOccurrences", forKey: .type)
                try container.encode(count, forKey: .count)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
            case "never":
                self = .never
            case "onDate":
                let date = try container.decode(Date.self, forKey: .date)
                self = .onDate(date)
            case "afterOccurrences":
                let count = try container.decode(Int.self, forKey: .count)
                self = .afterOccurrences(count)
            default:
                self = .never
        }
    }
}

struct MonthlyByDay: Hashable, Codable {
    let weekday: Weekday
    let position: Position  // 1º, 2º, 3º, 4º, último
    
    enum Position: Int, Hashable, Codable, CaseIterable {
        case first = 1
        case second = 2
        case third = 3
        case fourth = 4
        case last = -1
        
        var displayName: String {
            switch self {
                case .first: return "First"
                case .second: return "Second"
                case .third: return "Third"
                case .fourth: return "Fourth"
                case .last: return "Last"
            }
        }
    }
}
