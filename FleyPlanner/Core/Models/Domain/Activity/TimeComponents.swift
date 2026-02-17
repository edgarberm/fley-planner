//
//  TimeComponents.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 17/2/26.
//

import Foundation

struct TimeComponents: Hashable, Codable {
    var hour: Int
    var minute: Int
    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    // ✅ Convenience init desde Date
    init(from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        self.hour = components.hour ?? 0
        self.minute = components.minute ?? 0
    }
    
    // ✅ Convertir a DateComponents de Foundation
    var dateComponents: DateComponents {
        DateComponents(hour: hour, minute: minute)
    }
    
    // ✅ Combinar con una fecha para obtener Date
    func applying(to date: Date, calendar: Calendar = .current) -> Date? {
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components)
    }
    
    // ✅ Display helpers
    var displayString: String {
        String(format: "%02d:%02d", hour, minute)
    }
    
    var displayString12h: String {
        let period = hour >= 12 ? "PM" : "AM"
        let hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", hour12, minute, period)
    }
}
