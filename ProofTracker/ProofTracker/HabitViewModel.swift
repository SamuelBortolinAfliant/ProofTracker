//
//  HabitViewModel.swift
//  ProofTracker
//
//  Created by Samuel Bortolin on 29/08/25.
//

import Foundation
import SwiftUI

@MainActor
final class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var showingCompletionCelebration = false
    
    private let userDefaultsKey = "SavedHabits"
    
    init() {
        loadHabits()
        if habits.isEmpty {
            setupSampleHabits()
        }
        checkAndResetHabits()
        // Don't show celebration on app startup - only when tasks are actually completed
        // checkCompletionCelebration()
        
        // Ensure celebration is hidden on app startup
        showingCompletionCelebration = false
    }
    
    private func setupSampleHabits() {
        habits = [
            Habit(
                title: "Read a book",
                requiredClassification: "book",
                frequency: .daily
            ),
            Habit(
                title: "Drink water",
                requiredClassification: "water bottle",
                frequency: .daily
            ),
            Habit(
                title: "Tidy desk",
                requiredClassification: "keyboard",
                frequency: .weekly
            )
        ]
        saveHabits()
    }
    
    // MARK: - Persistence
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
        
        // Ensure completion celebration is initially false when loading habits
        showingCompletionCelebration = false
        
        // Don't check celebration state on app startup - only when actually completing tasks
        // DispatchQueue.main.async {
        //     self.verifyCelebrationState()
        // }
    }
    
    // MARK: - Habit Management
    
    func toggleCompletion(for habitID: UUID) {
        if let index = habits.firstIndex(where: { $0.id == habitID }) {
            let wasCompleted = habits[index].isCompleted
            habits[index].isCompleted.toggle()
            
            if habits[index].isCompleted {
                habits[index].completedDate = Date()
            } else {
                habits[index].completedDate = nil
            }
            
            saveHabits()
            
            // Only check for celebration when completing a task, not when marking as incomplete
            if !wasCompleted && habits[index].isCompleted {
                checkCompletionCelebration()
            } else if wasCompleted && !habits[index].isCompleted {
                // If marking as incomplete, hide celebration immediately
                showingCompletionCelebration = false
                print("Task marked incomplete, hiding celebration")
            }
        }
    }
    
    func checkAndResetHabits() {
        var needsSave = false
        
        for index in habits.indices {
            // Only reset daily and weekly habits, not one-time tasks
            if habits[index].frequency != .oneTime && habits[index].needsReset {
                habits[index].isCompleted = false
                habits[index].completedDate = nil
                habits[index].lastResetDate = Date()
                needsSave = true
            }
        }
        
        if needsSave {
            saveHabits()
        }
        
        // Reset completion celebration if any habits were reset
        if needsSave {
            showingCompletionCelebration = false
        }
    }
    
    func resetAllHabits() {
        for index in habits.indices {
            // Only reset daily and weekly habits, not one-time tasks
            if habits[index].frequency != .oneTime {
                habits[index].isCompleted = false
                habits[index].completedDate = nil
                habits[index].lastResetDate = Date()
            }
        }
        saveHabits()
    }
    
    private func checkCompletionCelebration() {
        // Check if all habits are completed (including one-time tasks)
        let allHabits = habits
        
        // Don't show celebration if there are no habits
        guard !allHabits.isEmpty else {
            showingCompletionCelebration = false
            return
        }
        
        let allCompleted = allHabits.allSatisfy { $0.isCompleted }
        
        // Show celebration if ALL habits are completed
        if allCompleted && allHabits.count > 0 {
            showingCompletionCelebration = true
        } else {
            // Always hide celebration if not all habits are completed
            showingCompletionCelebration = false
        }
        
        // Debug print to help troubleshoot
        print("Completion Check: \(allHabits.count) total habits, \(allHabits.filter { $0.isCompleted }.count) completed, showing celebration: \(showingCompletionCelebration)")
    }
    
    // MARK: - CRUD Operations
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
        // Don't check completion celebration when adding a new task
        // checkCompletionCelebration()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
            // No completion check needed for editing - just changing details
        }
    }
    
    func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
        saveHabits()
        checkCompletionCelebration()
    }
    
    func deleteHabit(withID id: UUID) {
        habits.removeAll { $0.id == id }
        saveHabits()
        checkCompletionCelebration()
    }
    
    func moveHabit(from source: IndexSet, to destination: Int) {
        habits.move(fromOffsets: source, toOffset: destination)
        saveHabits()
        // No need to check completion for reordering
    }
    
    // MARK: - Debug/Utility Methods
    
    func resetCompletionCelebration() {
        showingCompletionCelebration = false
    }
    
    func refreshCompletionState() {
        // Force refresh the completion state by checking and resetting habits
        checkAndResetHabits()
        checkCompletionCelebration()
    }
    
    func forceHideCelebration() {
        showingCompletionCelebration = false
        print("Forced celebration to be hidden")
    }
    
    private func verifyCelebrationState() {
        let allHabits = habits
        let allCompleted = allHabits.allSatisfy { $0.isCompleted }
        
        // Show celebration if ALL habits are completed (including one-time tasks)
        if allCompleted && !allHabits.isEmpty {
            showingCompletionCelebration = true
        } else {
            showingCompletionCelebration = false
        }
        
        print("State verification: \(allHabits.count) total habits, \(allHabits.filter { $0.isCompleted }.count) completed, celebration: \(showingCompletionCelebration)")
    }
}
