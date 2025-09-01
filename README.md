# ProofTracker - AI-Powered Habit Tracking App

## App Overview

ProofTracker is an innovative iOS application that combines traditional habit tracking with AI-powered image recognition to verify task completion. The app addresses the common problem of users marking tasks as complete without actually doing them, by requiring photographic proof of completion.

## Core Concept

The app uses Core ML models to analyze photos and verify that users have completed their intended tasks. For example, if a user has a task "Read a book," they must take a photo of a book to mark it complete. The AI classifier determines if the image matches the required classification, ensuring genuine task completion rather than false checkmarks. The completion celebration appears when ALL tasks (daily, weekly, and one-time) are finished.

## Key Features

- **AI-Powered Verification**: Uses machine learning models to verify task completion through photos
- **Flexible Task Management**: Support for daily, weekly, and one-time tasks
- **Smart Reset System**: Automatically resets daily/weekly tasks based on time intervals
- **Completion Celebration**: Motivational celebration screen when all tasks are completed
- **Search & Organization**: Easy task finding and management capabilities

## Technical Implementation

Built with SwiftUI and Core ML, the app integrates multiple machine learning models for robust image classification. The system automatically resets recurring tasks and maintains user progress across app sessions through persistent storage. The app follows MVVM architecture patterns and uses UserDefaults for data persistence.

## Screenshots Directory

Screenshots should be placed in the `screenshots/` directory with the following naming convention:
- `01_initial_page.png` - Main app interface showing task list
- `02_success_page.png` - Task completion with successful photo verification
- `03_fail_page.png` - Failed photo verification attempt
- `04_congrats_page.png` - Completion celebration screen
- `05_delete_page.png` - Task deletion confirmation
- `06_add_page.png` - Task addition interface
- `07_edit_page.png` - Task editing interface

## Installation & Execution

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- macOS 14.0+ for development
- iOS device or simulator for testing

### Setup Instructions
1. Clone the repository to your local machine
2. Open `ProofTracker.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project (⌘+R)

### Running on Device
1. Connect your iOS device via USB
2. In Xcode, select your device as the run destination
3. Trust the developer certificate on your device
4. Build and run the project

## Usage Instructions

1. **Adding Tasks**: Tap the + button to create new habits with required classifications
2. **Completing Tasks**: Tap the camera icon, take a photo, and let AI verify completion
3. **Managing Tasks**: Use the buttons to edit or delete tasks
4. **Search**: Use the search bar to quickly find specific tasks
5. **Task Types**: Set frequency as daily, weekly, or one-time based on your needs
6. **Photo Verification**: Ensure good lighting and clear images for better AI recognition

## Troubleshooting

- **Camera Access**: Ensure camera permissions are granted in device settings
- **ML Model Issues**: Verify Core ML models are properly included in the app bundle
- **Performance**: For older devices, consider reducing image resolution in ImagePicker
- **Photo Recognition**: If AI fails to recognize objects, try different angles or better lighting
- **App Crashes**: Ensure you're running the latest iOS version and have sufficient device storage
