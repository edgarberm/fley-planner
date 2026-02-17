//
//  OccurrenceGenerator.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 17/2/26.
//

/// RESUME
/// ✅ Genera fechas para todos los tipos de Frequency
/// ✅ Aplica overrides (cancelaciones, cambios de hora, participantes)
/// ✅ Soporta RecurrenceEnd (.never, .onDate, .afterOccurrences)
/// ✅ Maneja edge cases (meses con menos días, etc.)
/// ✅ O(1) lookup de overrides con Dictionary
/// ✅ Occurrences ordenadas por startDate

/// USAGE:
/// // Generar occurrences para esta semana
/// let today = Date()
/// let weekRange = DateInterval(
///     start: Calendar.current.startOfDay(for: today),
///     end: Calendar.current.date(byAdding: .day, value: 7, to: today)!
/// )

/// let occurrences = OccurrenceGenerator.generate(
///     for: activities,
///     overrides: overrides,
///     in: weekRange
/// )

/// Para un mes
/// let monthRange = DateInterval(
///     start: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: today))!,
///     end: Calendar.current.date(byAdding: .month, value: 1, to: today)!
/// )

/// let monthOccurrences = OccurrenceGenerator.generate(
///     for: activities,
///     overrides: overrides,
///     in: monthRange
/// )

import Foundation

struct OccurrenceGenerator {
    // MARK: - Public API
    
    /// Genera occurrences para una actividad en un rango de fechas
    static func generate(
        for activity: Activity,
        overrides: [ActivityOverride],
        in range: DateInterval,
        calendar: Calendar = .current
    ) -> [ActivityOccurrence] {
        
        // 1. Generar todas las fechas según la recurrencia
        let dates = generateDates(
            for: activity.recurrence,
            in: range,
            calendar: calendar
        )
        
        // 2. Indexar overrides por fecha para búsqueda O(1)
        let overridesByDate = Dictionary(
            uniqueKeysWithValues: overrides
                .filter { $0.activityID == activity.id }
                .map { (calendar.startOfDay(for: $0.date), $0) }
        )
        
        // 3. Construir occurrences
        return dates.compactMap { date in
            buildOccurrence(
                for: activity,
                on: date,
                override: overridesByDate[calendar.startOfDay(for: date)],
                calendar: calendar
            )
        }
    }
    
    /// Genera occurrences para múltiples actividades en un rango
    static func generate(
        for activities: [Activity],
        overrides: [ActivityOverride],
        in range: DateInterval,
        calendar: Calendar = .current
    ) -> [ActivityOccurrence] {
        activities
            .flatMap { activity in
                generate(
                    for: activity,
                    overrides: overrides.filter { $0.activityID == activity.id },
                    in: range,
                    calendar: calendar
                )
            }
            .sorted { $0.startDate < $1.startDate }
    }
    
    // MARK: - Date Generation
    
    static func generateDates(
        for rule: RecurrenceRule,
        in range: DateInterval,
        calendar: Calendar = .current
    ) -> [Date] {
        
        // Determinar fecha de inicio efectiva
        let effectiveStart = max(
            calendar.startOfDay(for: rule.startDate),
            calendar.startOfDay(for: range.start)
        )
        
        // Determinar fecha de fin efectiva
        let effectiveEnd: Date = {
            switch rule.end {
            case .never:
                return range.end
            case .onDate(let date):
                return min(calendar.startOfDay(for: date), range.end)
            case .afterOccurrences:
                return range.end  // Se filtrará después
            }
        }()
        
        guard effectiveStart <= effectiveEnd else { return [] }
        
        // Generar fechas según frecuencia
        var dates: [Date] = []
        
        switch rule.frequency {
        case .daily:
            dates = generateDaily(
                from: effectiveStart,
                to: effectiveEnd,
                interval: rule.interval,
                calendar: calendar
            )
            
        case .weekly:
            let weekdays = rule.weekdays ?? []
            dates = generateWeekly(
                from: effectiveStart,
                to: effectiveEnd,
                interval: rule.interval,
                weekdays: weekdays,
                calendar: calendar
            )
            
        case .workingDays:
            dates = generateWorkingDays(
                from: effectiveStart,
                to: effectiveEnd,
                interval: rule.interval,
                calendar: calendar
            )
            
        case .weekend:
            dates = generateWeekend(
                from: effectiveStart,
                to: effectiveEnd,
                interval: rule.interval,
                calendar: calendar
            )
            
        case .monthly:
            let day = rule.monthlyDay ?? calendar.component(.day, from: rule.startDate)
            dates = generateMonthly(
                from: effectiveStart,
                to: effectiveEnd,
                interval: rule.interval,
                day: day,
                calendar: calendar
            )
            
        case .monthlyByDay:
            guard let monthlyByDay = rule.monthlyByDay else { return [] }
            dates = generateMonthlyByDay(
                from: effectiveStart,
                to: effectiveEnd,
                interval: rule.interval,
                monthlyByDay: monthlyByDay,
                calendar: calendar
            )
        }
        
        // Filtrar por afterOccurrences si aplica
        if case .afterOccurrences(let count) = rule.end {
            // Contar desde el startDate real (no el range)
            let allDatesFromStart = generateAllDatesFromStart(
                for: rule,
                calendar: calendar
            )
            
            let validDates = Set(allDatesFromStart.prefix(count).map {
                calendar.startOfDay(for: $0)
            })
            
            return dates.filter { validDates.contains(calendar.startOfDay(for: $0)) }
        }
        
        return dates
    }
    
    // MARK: - Frequency Generators
    
    private static func generateDaily(
        from start: Date,
        to end: Date,
        interval: Int,
        calendar: Calendar
    ) -> [Date] {
        var dates: [Date] = []
        var current = start
        
        while current <= end {
            dates.append(current)
            guard let next = calendar.date(
                byAdding: .day,
                value: interval,
                to: current
            ) else { break }
            current = next
        }
        
        return dates
    }
    
    private static func generateWeekly(
        from start: Date,
        to end: Date,
        interval: Int,
        weekdays: Set<Weekday>,
        calendar: Calendar
    ) -> [Date] {
        guard !weekdays.isEmpty else { return [] }
        
        var dates: [Date] = []
        
        // Encontrar el inicio de la semana actual
        var weekStart = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: start)
        ) ?? start
        
        while weekStart <= end {
            // Para cada día de la semana requerido
            for weekday in weekdays.sorted(by: { $0.rawValue < $1.rawValue }) {
                guard let date = calendar.date(
                    bySetting: .weekday,
                    value: weekday.rawValue,
                    of: weekStart
                ) else { continue }
                
                let dayStart = calendar.startOfDay(for: date)
                
                if dayStart >= start && dayStart <= end {
                    dates.append(dayStart)
                }
            }
            
            // Avanzar al siguiente intervalo de semanas
            guard let nextWeek = calendar.date(
                byAdding: .weekOfYear,
                value: interval,
                to: weekStart
            ) else { break }
            weekStart = nextWeek
        }
        
        return dates.sorted()
    }
    
    private static func generateWorkingDays(
        from start: Date,
        to end: Date,
        interval: Int,
        calendar: Calendar
    ) -> [Date] {
        var dates: [Date] = []
        var current = start
        var count = 0
        
        while current <= end {
            let weekday = calendar.component(.weekday, from: current)
            let isWorkingDay = weekday >= 2 && weekday <= 6  // Lun-Vie
            
            if isWorkingDay {
                if count % interval == 0 {
                    dates.append(current)
                }
                count += 1
            }
            
            guard let next = calendar.date(
                byAdding: .day,
                value: 1,
                to: current
            ) else { break }
            current = next
        }
        
        return dates
    }
    
    private static func generateWeekend(
        from start: Date,
        to end: Date,
        interval: Int,
        calendar: Calendar
    ) -> [Date] {
        var dates: [Date] = []
        var current = start
        var weekendCount = 0
        var lastWeekend: Int? = nil
        
        while current <= end {
            let weekday = calendar.component(.weekday, from: current)
            let weekOfYear = calendar.component(.weekOfYear, from: current)
            let isWeekend = weekday == 1 || weekday == 7  // Dom o Sab
            
            if isWeekend {
                // Nuevo fin de semana
                if lastWeekend != weekOfYear {
                    lastWeekend = weekOfYear
                    weekendCount += 1
                }
                
                // Solo añadir si corresponde al intervalo
                if weekendCount % interval == 0 {
                    dates.append(current)
                }
            }
            
            guard let next = calendar.date(
                byAdding: .day,
                value: 1,
                to: current
            ) else { break }
            current = next
        }
        
        return dates
    }
    
    private static func generateMonthly(
        from start: Date,
        to end: Date,
        interval: Int,
        day: Int,
        calendar: Calendar
    ) -> [Date] {
        var dates: [Date] = []
        
        var components = calendar.dateComponents([.year, .month], from: start)
        
        while true {
            components.day = day
            
            guard let date = calendar.date(from: components),
                  let monthEnd = calendar.date(
                    byAdding: DateComponents(month: 1, day: -1),
                    to: calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
                  ) else { break }
            
            // Ajustar si el día no existe en el mes (ej: 31 en febrero)
            let actualDay = min(day, calendar.component(.day, from: monthEnd))
            components.day = actualDay
            
            guard let adjustedDate = calendar.date(from: components) else { break }
            
            let dayStart = calendar.startOfDay(for: adjustedDate)
            
            if dayStart > end { break }
            
            if dayStart >= start {
                dates.append(dayStart)
            }
            
            guard let nextMonth = calendar.date(
                byAdding: .month,
                value: interval,
                to: adjustedDate
            ) else { break }
            
            components = calendar.dateComponents([.year, .month], from: nextMonth)
        }
        
        return dates
    }
    
    private static func generateMonthlyByDay(
        from start: Date,
        to end: Date,
        interval: Int,
        monthlyByDay: MonthlyByDay,
        calendar: Calendar
    ) -> [Date] {
        var dates: [Date] = []
        
        var components = calendar.dateComponents([.year, .month], from: start)
        
        while true {
            guard let monthStart = calendar.date(from: components) else { break }
            
            if monthStart > end { break }
            
            // Encontrar el Nth weekday del mes
            if let date = findNthWeekday(
                monthlyByDay.weekday,
                position: monthlyByDay.position,
                in: monthStart,
                calendar: calendar
            ) {
                let dayStart = calendar.startOfDay(for: date)
                
                if dayStart >= start && dayStart <= end {
                    dates.append(dayStart)
                }
            }
            
            guard let nextMonth = calendar.date(
                byAdding: .month,
                value: interval,
                to: monthStart
            ) else { break }
            
            components = calendar.dateComponents([.year, .month], from: nextMonth)
        }
        
        return dates
    }
    
    // MARK: - Helpers
    
    /// Encuentra el Nth weekday de un mes
    private static func findNthWeekday(
        _ weekday: Weekday,
        position: MonthlyByDay.Position,
        in monthDate: Date,
        calendar: Calendar
    ) -> Date? {
        let monthComponents = calendar.dateComponents([.year, .month], from: monthDate)
        
        guard let monthStart = calendar.date(from: monthComponents),
              let monthRange = calendar.range(of: .day, in: .month, for: monthStart) else {
            return nil
        }
        
        // Generar todos los días del mes con ese weekday
        var matchingDays: [Date] = []
        
        for day in monthRange {
            var components = monthComponents
            components.day = day
            
            guard let date = calendar.date(from: components) else { continue }
            
            let dayWeekday = calendar.component(.weekday, from: date)
            if dayWeekday == weekday.rawValue {
                matchingDays.append(date)
            }
        }
        
        guard !matchingDays.isEmpty else { return nil }
        
        switch position {
        case .first: return matchingDays.first
        case .second: return matchingDays.count >= 2 ? matchingDays[1] : nil
        case .third: return matchingDays.count >= 3 ? matchingDays[2] : nil
        case .fourth: return matchingDays.count >= 4 ? matchingDays[3] : nil
        case .last: return matchingDays.last
        }
    }
    
    /// Genera todas las fechas desde startDate (sin límite de range)
    /// Solo para calcular afterOccurrences
    private static func generateAllDatesFromStart(
        for rule: RecurrenceRule,
        calendar: Calendar
    ) -> [Date] {
        // Usar un rango amplio (10 años)
        let farFuture = calendar.date(
            byAdding: .year,
            value: 10,
            to: rule.startDate
        ) ?? rule.startDate
        
        let fullRange = DateInterval(start: rule.startDate, end: farFuture)
        
        // Generar sin filtro de afterOccurrences para evitar recursión
        return generateDates(
            for: RecurrenceRule(
                frequency: rule.frequency,
                interval: rule.interval,
                weekdays: rule.weekdays,
                monthlyDay: rule.monthlyDay,
                monthlyByDay: rule.monthlyByDay,
                startDate: rule.startDate,
                end: .never,  // Sin límite
                startTime: rule.startTime,
                endTime: rule.endTime
            ),
            in: fullRange,
            calendar: calendar
        )
    }
    
    // MARK: - Occurrence Builder
    
    private static func buildOccurrence(
        for activity: Activity,
        on date: Date,
        override: ActivityOverride?,
        calendar: Calendar
    ) -> ActivityOccurrence? {
        
        // Si está cancelada, no renderizar
        if override?.cancelled == true {
            return nil
        }
        
        // Resolver startTime y endTime
        let startTime = override?.overriddenStartTime ?? activity.recurrence.startTime
        let endTime = override?.overriddenEndTime ?? activity.recurrence.endTime
        
        // Combinar fecha con hora
        guard let startDate = startTime.applying(to: date, calendar: calendar),
              let endDate = endTime.applying(to: date, calendar: calendar) else {
            return nil
        }
        
        // Resolver subjects y participants
        let subjects = override?.overriddenSubjects ?? activity.subjects
        let participants = override?.overriddenParticipants ?? activity.participants
        
        // Resolver completionStatus
        let completionStatus: CompletionStatus?
        if activity.tracksCompletion {
            completionStatus = override?.completionStatus ?? .pending
        } else {
            completionStatus = nil
        }
        
        return ActivityOccurrence(
            activityID: activity.id,
            seriesID: activity.seriesID,
            overrideID: override?.id,
            date: date,
            startDate: startDate,
            endDate: endDate,
            title: activity.title,
            notes: activity.notes,
            subjects: subjects,
            participants: participants,
            tracksCompletion: activity.tracksCompletion,
            completionStatus: completionStatus,
            isCancelled: false,
            isModified: override != nil
        )
    }
}
