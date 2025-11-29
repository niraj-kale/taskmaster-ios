# TaskMaster iOS - Architecture

## Overview
This iOS application follows **Clean Architecture** principles with **MVVM** pattern, built using **Swift** and **SwiftUI**.

## Architecture Layers

### 1. Presentation Layer
- **Views**: SwiftUI views
- **ViewModels**: Business logic presentation, state management
- **Components**: Reusable UI components

### 2. Domain Layer
- **Entities**: Core business models (Task, User, Category)
- **Use Cases**: Business logic operations
- **Repository Interfaces**: Protocols defining data operations

### 3. Data Layer
- **Repositories**: Implementations of repository interfaces
- **Data Sources**: 
  - Remote: Firebase Firestore
  - Local: Core Data
- **Models**: DTOs and data mapping

## Tech Stack
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM + Clean Architecture
- **Async**: Async/Await + Combine
- **Local Database**: Core Data
- **Backend**: Firebase (Auth + Firestore)
- **Dependency Injection**: Manual/Protocol-based
- **Testing**: XCTest

## Data Flow
```
User Input → View → ViewModel → Use Case → Repository → Data Source
                ↓                                          ↓
             State Update ← ViewModel ← Use Case ← Repository
```

## Key Design Decisions
1. **SwiftUI**: Modern, declarative UI
2. **Combine**: Reactive data flow
3. **Core Data**: Robust offline-first storage
4. **Protocol-Oriented**: Testability and flexibility

## Testing Strategy
- **Unit Tests**: ViewModels, Use Cases, Repositories
- **UI Tests**: Critical user flows
- **Target Coverage**: 70%+
