# TaskMaster iOS

A professional task management app demonstrating clean architecture (MVVM) for iOS with a Firebase backend for cloud sync.

## Features

### Core Functionality
- **User Authentication**: Email/Password and Google Sign-In support
- **Task CRUD Operations**: Create, read, update, and delete tasks
- **Task Lists/Categories**: Organize tasks with customizable categories
- **Cloud Sync**: Real-time synchronization with Firebase Firestore
- **Search & Filter**: Find tasks quickly with search and filter options

### Screens
1. **Authentication Screen**: Login and registration with email/password or Google Sign-In
2. **Task List Screen**: Main screen displaying tasks with filtering, sorting, and search capabilities
3. **Task Detail/Edit Screen**: Create or edit tasks with title, description, priority, status, due date, and category
4. **Settings Screen**: User profile management, account settings, and logout

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** architecture pattern:

```
TaskMaster/
├── App/                    # App entry point and main configuration
│   ├── TaskMasterApp.swift
│   └── ContentView.swift
├── Models/                 # Data models
│   ├── User.swift
│   ├── Task.swift
│   └── TaskCategory.swift
├── ViewModels/             # View models containing business logic
│   ├── AuthenticationViewModel.swift
│   ├── TaskListViewModel.swift
│   ├── TaskDetailViewModel.swift
│   └── SettingsViewModel.swift
├── Views/                  # SwiftUI views
│   ├── Authentication/
│   │   └── AuthenticationView.swift
│   ├── TaskList/
│   │   ├── TaskListView.swift
│   │   └── TaskRowView.swift
│   ├── TaskDetail/
│   │   └── TaskDetailView.swift
│   └── Settings/
│       └── SettingsView.swift
├── Services/               # Business logic and API services
│   ├── AuthenticationService.swift
│   └── FirestoreService.swift
├── Extensions/             # Swift extensions
│   ├── Color+Extensions.swift
│   └── Date+Extensions.swift
└── Resources/              # Assets and configuration files
    ├── Assets.xcassets
    ├── GoogleService-Info.plist
    └── Info.plist
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Firebase Account

## Dependencies

The app uses Swift Package Manager for dependency management:

- [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk) - Authentication and Firestore
- [GoogleSignIn iOS](https://github.com/google/GoogleSignIn-iOS) - Google Sign-In support

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/niraj-kale/taskmaster-ios.git
cd taskmaster-ios
```

### 2. Firebase Configuration

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Add an iOS app to your project with bundle ID: `com.taskmaster.ios`
4. Download the `GoogleService-Info.plist` file
5. Replace the placeholder `TaskMaster/Resources/GoogleService-Info.plist` with your downloaded file

### 3. Enable Firebase Services

In the Firebase Console:
1. Enable **Authentication** and configure:
   - Email/Password sign-in method
   - Google sign-in method
2. Enable **Cloud Firestore** and set up security rules

### 4. Configure Google Sign-In

1. In the Firebase Console, go to Authentication > Sign-in method > Google
2. Enable Google sign-in
3. Copy the `REVERSED_CLIENT_ID` from your `GoogleService-Info.plist`
4. Update `Info.plist` with your `REVERSED_CLIENT_ID` in `CFBundleURLSchemes`

### 5. Firestore Security Rules

Add the following security rules to your Firestore database:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /tasks/{taskId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
    
    match /categories/{categoryId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
  }
}
```

### 6. Build and Run

Open `TaskMaster.xcodeproj` in Xcode:

```bash
open TaskMaster.xcodeproj
```

Then build and run the project (⌘+R).

## Usage

### Authentication
- **Sign Up**: Create a new account with email and password
- **Sign In**: Log in with existing credentials
- **Google Sign-In**: Quick authentication with Google account
- **Password Reset**: Request password reset via email

### Task Management
- **Create Task**: Tap the + button to create a new task
- **Edit Task**: Tap on a task to view and edit details
- **Complete Task**: Swipe right on a task to mark as complete
- **Delete Task**: Swipe left on a task to delete

### Filtering & Search
- **Filter by Status**: All, Pending, In Progress, Completed
- **Filter by Category**: Select a specific category
- **Sort Options**: Date Created, Due Date, Priority, Title
- **Search**: Type in the search bar to find tasks

### Categories
- Pre-configured default categories: Personal, Work, Shopping, Health, Education
- Each category has a custom color and icon

## Testing

Run the test suite in Xcode:
```bash
xcodebuild test -project TaskMaster.xcodeproj -scheme TaskMaster -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
