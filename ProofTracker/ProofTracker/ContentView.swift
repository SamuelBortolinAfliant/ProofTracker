//
//  ContentView.swift
//  ProofTracker
//
//  Created by Samuel Bortolin on 29/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var habitViewModel = HabitViewModel()
    @State private var showingAddHabit = false
    @State private var habitToEdit: Habit?
    @State private var searchText = ""
    
    var filteredHabits: [Habit] {
        let allHabits = searchText.isEmpty ? habitViewModel.habits : habitViewModel.habits.filter { habit in
            habit.title.localizedCaseInsensitiveContains(searchText) ||
            habit.requiredClassification.localizedCaseInsensitiveContains(searchText)
        }
        
        // Sort: incomplete habits first, then completed habits
        return allHabits.sorted { first, second in
            if first.isCompleted == second.isCompleted {
                // If completion status is the same, maintain original order
                return first.id.uuidString < second.id.uuidString
            } else {
                // Incomplete habits come first
                return !first.isCompleted && second.isCompleted
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredHabits) { habit in
                    HabitRowView(
                        habit: habit,  // Pass habit directly, no binding
                        onCameraTapped: {
                            // This parameter is no longer needed but kept for compatibility
                        },
                        onHabitCompleted: { habitID in
                            // Ensure this happens on the main actor
                            DispatchQueue.main.async {
                                habitViewModel.toggleCompletion(for: habitID)
                            }
                        },
                        onEditHabit: { habit in
                            habitToEdit = habit
                        },
                        onDeleteHabit: { habitID in
                            habitViewModel.deleteHabit(withID: habitID)
                        }
                    )
                }
                .onMove(perform: moveHabits)
            }
            .searchable(text: $searchText, prompt: "Search habits...")
            .navigationTitle("Proof Tracker")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddHabit = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                HabitFormView(habitViewModel: habitViewModel)
            }
            .sheet(item: $habitToEdit) { habit in
                HabitFormView(habitViewModel: habitViewModel, habitToEdit: habit)
            }
            .overlay {
                if habitViewModel.showingCompletionCelebration {
                    CompletionCelebrationView(
                        isPresented: $habitViewModel.showingCompletionCelebration
                    )
                }
            }
        }
    }
    
    private func moveHabits(from source: IndexSet, to destination: Int) {
        // Only allow moving when not searching to prevent index mismatches
        if searchText.isEmpty {
            habitViewModel.moveHabit(from: source, to: destination)
        }
    }
}

#Preview {
    ContentView()
}
