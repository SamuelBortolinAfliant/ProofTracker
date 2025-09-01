//
//  HabitRowView.swift
//  ProofTracker
//
//  Created by Samuel Bortolin on 29/08/25.
//

import SwiftUI

struct HabitRowView: View {
    let habit: Habit  // Remove @Binding, use direct parameter
    let onCameraTapped: () -> Void
    let onHabitCompleted: (UUID) -> Void  // Add callback for habit completion
    let onEditHabit: (Habit) -> Void  // Add callback for editing
    let onDeleteHabit: (UUID) -> Void  // Add callback for deleting
    
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isProcessingImage = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack {
            // Habit title
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.title)
                    .font(.headline)
                    .foregroundColor(habit.isCompleted ? .secondary : .primary)
                
                HStack {
                    Text("Requires: \(habit.requiredClassification)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(habit.frequency.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            habit.frequency == .daily ? Color.blue.opacity(0.2) :
                            habit.frequency == .weekly ? Color.purple.opacity(0.2) :
                            Color.gray.opacity(0.2)
                        )
                        .foregroundColor(
                            habit.frequency == .daily ? .blue :
                            habit.frequency == .weekly ? .purple :
                            .gray
                        )
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            // Edit button
            Button(action: {
                onEditHabit(habit)
            }) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Delete button
            Button(action: {
                showingDeleteAlert = true
            }) {
                Image(systemName: "trash.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Completion status or camera button
            if habit.isCompleted {
                Button(action: {
                    print("↩️ Undo button tapped for completed habit: \(habit.title)")
                    onHabitCompleted(habit.id) // This will toggle it back to incomplete
                }) {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Tap to undo completion")
            } else {
                Button(action: {
                    print("📸 Camera button tapped for habit: \(habit.title)")
                    showingImagePicker = true
                }) {
                    if isProcessingImage {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "camera.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isProcessingImage)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            print("🔄 onChange triggered - oldValue: \(oldValue?.description ?? "nil"), newValue: \(newValue?.description ?? "nil")")
            if let image = newValue {
                print("🖼️ Image selected, starting processing")
                // Add a small delay to ensure the binding is fully updated
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    processSelectedImage(image)
                }
            } else {
                print("⚠️ Image is nil in onChange")
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .alert("Delete Habit", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDeleteHabit(habit.id)
            }
        } message: {
            Text("Are you sure you want to delete '\(habit.title)'? This action cannot be undone.")
        }
    }
    
    private func processSelectedImage(_ image: UIImage) {
        print("🔄 Starting image processing for habit: \(habit.title)")
        isProcessingImage = false  // Don't show loading state in button
        
        // Don't show processing alert - go straight to classification
        
        ImageClassifier.classify(image: image) { result in
            print("📱 Image classification completed for habit: \(habit.title)")
            
            DispatchQueue.main.async {
                switch result {
                case .success(let classification):
                    print("✅ Classification successful: '\(classification)' for habit: \(habit.title)")
                    print("🔍 Required: '\(habit.requiredClassification)', Detected: '\(classification)'")
                    
                    // Check if the classification contains the required classification
                    if classification.lowercased().contains(habit.requiredClassification.lowercased()) {
                        print("🎯 MATCH FOUND! Marking habit as complete")
                        // Use callback to update habit completion status
                        onHabitCompleted(habit.id)
                        alertTitle = "Success! 🎉"
                        alertMessage = "Great job! The AI detected '\(classification)' which matches your habit requirement. Your habit is now marked as complete!"
                    } else {
                        print("❌ No match found. Required: '\(habit.requiredClassification)', Got: '\(classification)'")
                        alertTitle = "Not Quite Right"
                        alertMessage = "The AI detected '\(classification)' but this doesn't match your habit requirement of '\(habit.requiredClassification)'. Please try taking another photo."
                    }
                    
                    // Show the result alert directly
                    showingAlert = true
                    
                case .failure(let error):
                    print("💥 Classification failed for habit: \(habit.title)")
                    print("🚨 Error: \(error.localizedDescription)")
                    alertTitle = "Classification Failed"
                    alertMessage = "Sorry, we couldn't analyze your photo: \(error.localizedDescription). Please try again."
                    
                    // Show the error alert directly
                    showingAlert = true
                }
                
                // Reset the selected image
                selectedImage = nil
                print("🔄 Image processing completed for habit: \(habit.title)")
            }
        }
    }
}

#Preview {
    HabitRowView(
        habit: Habit(
            title: "Read a book",
            requiredClassification: "book",
            isCompleted: false
        ),
        onCameraTapped: {},
        onHabitCompleted: { _ in },
        onEditHabit: { _ in },
        onDeleteHabit: { _ in }
    )
    .padding()
}
