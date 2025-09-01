//
//  CompletionCelebrationView.swift
//  ProofTracker
//
//  Created by Samuel Bortolin on 29/08/25.
//

import SwiftUI

struct CompletionCelebrationView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    // Allow dismissing by tapping the background
                    withAnimation(.easeOut(duration: 0.2)) {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 30) {
                // Celebration emoji
                Text("🎉")
                    .font(.system(size: 80))
                    .scaleEffect(isPresented ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: isPresented)
                
                // Congratulations text
                VStack(spacing: 16) {
                    Text("Congratulations!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("You've completed all your tasks!")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .opacity(isPresented ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.3).delay(0.2), value: isPresented)
                
                // Continue button
                Button("OK") {
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.easeOut(duration: 0.2)) {
                        isPresented = false
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.blue)
                .cornerRadius(12)
                .opacity(isPresented ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.3).delay(0.4), value: isPresented)
                .allowsHitTesting(isPresented) // Ensure button is only interactive when visible
                .contentShape(Rectangle()) // Ensure the entire button area is tappable
                .zIndex(1) // Ensure button is above other elements
            }
            .padding(40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                isPresented = true
            }
        }

    }
}

#Preview {
    CompletionCelebrationView(isPresented: .constant(true))
}
