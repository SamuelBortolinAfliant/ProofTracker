//
//  Habit.swift
//  ProofTracker
//
//  Created by Samuel Bortolin on 29/08/25.
//

import Foundation

enum HabitFrequency: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case oneTime = "One-time"
    
    var displayName: String {
        return self.rawValue
    }
}

struct Habit: Identifiable, Codable {
    let id: UUID
    let title: String
    let requiredClassification: String
    var isCompleted: Bool
    var frequency: HabitFrequency
    var lastResetDate: Date
    var completedDate: Date?
    
    init(id: UUID = UUID(), title: String, requiredClassification: String, isCompleted: Bool = false, frequency: HabitFrequency = .daily) {
        self.id = id
        self.title = title
        self.requiredClassification = requiredClassification
        self.isCompleted = isCompleted
        self.frequency = frequency
        self.lastResetDate = Date()
        self.completedDate = isCompleted ? Date() : nil
    }
    
    var needsReset: Bool {
        // One-time tasks never need reset
        if frequency == .oneTime {
            return false
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        switch frequency {
        case .daily:
            return !calendar.isDate(lastResetDate, inSameDayAs: now)
        case .weekly:
            // Use dateInterval to check if we're in the same week
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now)
            let lastWeekInterval = calendar.dateInterval(of: .weekOfYear, for: lastResetDate)
            
            // Check if the intervals are different (different weeks)
            return weekInterval?.start != lastWeekInterval?.start
        case .oneTime:
            return false
        }
    }
}
