//
//  HabitFormView.swift
//  ProofTracker
//
//  Created by Samuel Bortolin on 29/08/25.
//

import SwiftUI

struct HabitFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var habitViewModel: HabitViewModel
    
    @State private var title: String = ""
    @State private var requiredClassification: String = ""
    @State private var frequency: HabitFrequency = .daily
    
    let habitToEdit: Habit?
    let isEditing: Bool
    
    init(habitViewModel: HabitViewModel, habitToEdit: Habit? = nil) {
        self.habitViewModel = habitViewModel
        self.habitToEdit = habitToEdit
        self.isEditing = habitToEdit != nil
        
        if let habit = habitToEdit {
            _title = State(initialValue: habit.title)
            _requiredClassification = State(initialValue: habit.requiredClassification)
            _frequency = State(initialValue: habit.frequency)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Details") {
                    TextField("Habit title", text: $title)
                    
                    TextField("Object to photograph", text: $requiredClassification, prompt: Text("Object to detect"))
                    
                    Picker("Frequency", selection: $frequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button(isEditing ? "Update Habit" : "Add Habit") {
                        saveHabit()
                    }
                    .disabled(title.isEmpty || requiredClassification.isEmpty)
                }
            }
            .navigationTitle(isEditing ? "Edit Habit" : "New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveHabit() {
        if isEditing, let habit = habitToEdit {
            let updatedHabit = Habit(
                id: habit.id,
                title: title,
                requiredClassification: requiredClassification,
                isCompleted: habit.isCompleted,
                frequency: frequency
            )
            habitViewModel.updateHabit(updatedHabit)
        } else {
            let newHabit = Habit(
                title: title,
                requiredClassification: requiredClassification,
                frequency: frequency
            )
            habitViewModel.addHabit(newHabit)
        }
        dismiss()
    }
}

#Preview {
    HabitFormView(habitViewModel: HabitViewModel())
}
