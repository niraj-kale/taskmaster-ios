# TaskMaster iOS 📱

<p align="center">
  <img src="screenshots/app-icon.png" alt="TaskMaster Icon" width="120"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-iOS%2015.0+-blue" alt="Platform"/>
  <img src="https://img.shields.io/badge/Swift-5.9-orange" alt="Swift"/>
  <img src="https://img.shields.io/badge/SwiftUI-3.0-brightgreen" alt="SwiftUI"/>
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License"/>
</p>

## 📖 Overview
TaskMaster is a modern task management application for iOS, built with **Swift** and **SwiftUI**. This project demonstrates **Clean Architecture**, **offline-first design**, and **Firebase integration** in a production-quality iOS app.

### Part of Multi-Platform Series
This is the **iOS implementation** of TaskMaster. See also:
- [TaskMaster Android](https://github.com/niraj-kale/taskmaster-android) - Kotlin + Jetpack Compose
- [TaskMaster Flutter](https://github.com/niraj-kale/taskmaster-flutter) - Dart + Flutter
- [TaskMaster React Native](https://github.com/niraj-kale/taskmaster-react-native) - TypeScript + React Native

## ✨ Features
- ✅ User authentication (Email/Password + Google Sign-In)
- ✅ Create, read, update, delete tasks
- ✅ Organize tasks by categories
- ✅ Priority levels and due dates
- ✅ Real-time cloud synchronization
- ✅ Offline-first with automatic sync
- ✅ Search and filter tasks
- ✅ Modern SwiftUI interface
- ✅ Dark mode support

## 📸 Screenshots
<!-- Add screenshots after UI is built -->
Coming soon...

## 🏗️ Architecture
This app follows **Clean Architecture** with **MVVM** pattern:
- **Presentation Layer**: SwiftUI views + ViewModels
- **Domain Layer**: Business logic + Use cases
- **Data Layer**: Repositories + Data sources (Firebase + Core Data)

[See detailed architecture documentation →](ARCHITECTURE.md)

## 🛠️ Tech Stack
| Category | Technology |
|----------|-----------|
| **Language** | Swift 5.9+ |
| **UI Framework** | SwiftUI |
| **Architecture** | MVVM + Clean Architecture |
| **Async** | Async/Await + Combine |
| **Local Database** | Core Data |
| **Backend** | Firebase (Auth + Firestore) |
| **Networking** | URLSession |
| **Dependency Injection** | Protocol-based DI |
| **Testing** | XCTest |

## 🚀 Getting Started

### Prerequisites
- macOS 13.0+
- Xcode 15.0+
- iOS 15.0+ device or simulator
- Firebase account

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/niraj-kale/taskmaster-ios.git
cd taskmaster-ios
```

2. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Download `GoogleService-Info.plist`
   - Add it to the Xcode project root

3. **Open in Xcode**
```bash
open TaskMaster.xcodeproj
```

4. **Build and Run**
   - Select target device/simulator
   - Press `Cmd + R`

## 🧪 Testing

### Run Unit Tests
```bash
# Command line
xcodebuild test -scheme TaskMaster -destination 'platform=iOS Simulator,name=iPhone 15'

# Or in Xcode: Cmd + U
```

### Test Coverage
- Target: 70%+
- Focus: ViewModels, Use Cases, Repositories

## 📁 Project Structure
```
TaskMaster/
├── Presentation/
│   ├── Screens/          # SwiftUI views
│   ├── ViewModels/       # View models
│   └── Components/       # Reusable UI components
├── Domain/
│   ├── Entities/         # Core business models
│   ├── UseCases/         # Business logic
│   └── RepositoryInterfaces/
├── Data/
│   ├── Repositories/     # Repository implementations
│   ├── DataSources/      # Firebase & Core Data
│   └── Models/           # DTOs
└── Core/
    ├── Utilities/
    ├── Extensions/
    └── Constants/
```

## 🎯 Key Learnings
This project showcases:
- Clean Architecture implementation in iOS
- SwiftUI best practices
- Offline-first data synchronization
- Firebase integration patterns
- Comprehensive testing strategies
- Modern Swift concurrency (async/await)

## 🔜 Future Enhancements
- [ ] Widget extension
- [ ] Apple Watch companion app
- [ ] Siri shortcuts integration
- [ ] App Clips for quick access
- [ ] CloudKit alternative backend

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author
**Niraj Kale**
- GitHub: [@niraj-kale](https://github.com/niraj-kale)
- LinkedIn: [nirajkale](https://www.linkedin.com/in/nirajkale/)

## 🙏 Acknowledgments
Part of a multi-platform architecture showcase demonstrating consistent patterns across iOS, Android, Flutter, and React Native.

---

**Note**: This is a portfolio project demonstrating expert-level iOS development skills.
EOF