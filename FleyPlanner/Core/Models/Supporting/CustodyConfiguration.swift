//
//  CustodyConfiguration.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

enum CustodyConfiguration: Codable {
    case livingTogether(primaryCaregiver: UUID?)
    case sharedCustody(parents: [UUID], schedule: CustodySchedule)
    case singleParent(parent: UUID)
    
    func getResponsibleAt(date: Date) -> UUID? {
        switch self {
            case .livingTogether(let primary):
                return primary
            case .sharedCustody(let parents, let schedule):
                return schedule.getResponsibleAt(date: date, parents: parents)
            case .singleParent(let parent):
                return parent
        }
    }
}

enum CustodySchedule: Codable {
    case weeklyAlternating(startsWithIndex: Int, startDate: Date)
    case biweekly(pattern: BiweeklyPattern)
    case weekdaysWeekends(weekdayParentIndex: Int, weekendParentIndex: Int)
    case custom(assignments: [DayAssignment])
    
    struct BiweeklyPattern: Codable {
        let parent1Index: Int
        let parent2Index: Int
        let parent1Days: Int
        let parent2Days: Int
        let parent1WeekendDays: Int
        let startDate: Date
    }
    
    struct DayAssignment: Codable {
        let date: Date
        let parentIndex: Int
    }
    
    func getResponsibleAt(date: Date, parents: [UUID]) -> UUID? {
        guard !parents.isEmpty else { return nil }
        
        switch self {
            case .weeklyAlternating(let startIndex, let startDate):
                guard parents.indices.contains(startIndex) else { return nil }
                
                let weeksSinceStart = Calendar.current.dateComponents(
                    [.weekOfYear],
                    from: startDate,
                    to: date
                ).weekOfYear ?? 0
                
                let currentParentIndex = (startIndex + weeksSinceStart) % parents.count
                return parents[currentParentIndex]
                
            case .biweekly(let pattern):
                return calculateBiweeklyPattern(date: date, pattern: pattern, parents: parents)
                
            case .weekdaysWeekends(let weekdayIndex, let weekendIndex):
                let isWeekend = Calendar.current.isDateInWeekend(date)
                let index = isWeekend ? weekendIndex : weekdayIndex
                guard parents.indices.contains(index) else { return nil }
                return parents[index]
                
            case .custom(let assignments):
                guard let assignment = assignments.first(where: {
                    Calendar.current.isDate($0.date, inSameDayAs: date)
                }) else { return nil }
                guard parents.indices.contains(assignment.parentIndex) else { return nil }
                return parents[assignment.parentIndex]
        }
    }
    
    private func calculateBiweeklyPattern(
        date: Date,
        pattern: BiweeklyPattern,
        parents: [UUID]
    ) -> UUID? {
        let daysSinceStart = Calendar.current.dateComponents(
            [.day],
            from: pattern.startDate,
            to: date
        ).day ?? 0
        
        let cycleLength = pattern.parent1Days + pattern.parent2Days + pattern.parent1WeekendDays
        let dayInCycle = daysSinceStart % cycleLength
        
        let index: Int
        if dayInCycle < pattern.parent1Days {
            index = pattern.parent1Index
        } else if dayInCycle < (pattern.parent1Days + pattern.parent2Days) {
            index = pattern.parent2Index
        } else {
            index = pattern.parent1Index
        }
        
        guard parents.indices.contains(index) else { return nil }
        return parents[index]
    }
}
