# 🚀 KTGK_LTDNT - Employee Management System

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

A comprehensive mobile application for managing employees, built with **Flutter** and **Firebase**. This project demonstrates a robust implementation of real-time data synchronization, advanced authentication flows, and premium UI/UX design.

---

## ✨ Key Features

- **🔐 Multi-Method Authentication**
  - Email & Password (Login/Register/Forgot Password)
  - **Phone OTP** Verification
  - **Google Sign-In** Integration
- **👥 Employee Management (CRUD)**
  - Real-time list updates with `StreamBuilder`
  - Advanced search and filtering
  - Detailed employee profiles
- **👤 User Profile**
  - Personal information management
  - Profile picture support (Base64 storage in Firestore)
- **🎨 Premium UI/UX**
  - Modern **Material 3** Design
  - Responsive layouts for all screen sizes
  - Smooth micro-animations using `flutter_animate`
  - Dark & Light mode support
- **🏗️ Architecture**
  - State management with **Riverpod** & **Provider**
  - Clean separation of concerns (UI, Business Logic, Data Layers)
  - Firestore offline persistence

---

## 📂 Project Structure

```text
lib/
├── models/         # Data models (Employee, UserProfile)
├── providers/      # State management (Auth, Employee, Theme)
├── screens/        # UI Screens (Auth, Employees, Profile, Home)
├── services/       # Firebase & logic services
├── utils/          # Helpers and validators
└── widgets/        # Reusable UI components
```

---

## 🛠️ Getting Started

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Node.js (for Firebase tools)

### 2. Firebase Configuration
1. **Initialize Firebase CLI:**
   ```bash
   dart pub global activate flutterfire_cli
   firebase login
   ```
2. **Configure the project:**
   ```bash
   flutterfire configure
   ```
   *This will generate `lib/firebase_options.dart` and register your apps.*

3. **Enable Firebase Services:**
   - **Authentication:** Enable Email, Google, and Phone providers.
   - **Firestore:** Create database in Test Mode.
   - **Messaging:** Enable for push notifications.

### 3. Platform Specifics

#### 🤖 Android
- Add your **SHA-1** and **SHA-256** fingerprints to Firebase Console for Google Sign-In and Phone Auth.
- Generate fingerprints: `cd android && ./gradlew signingReport`.

#### 🍎 iOS
- Run `pod install` in the `ios` directory.
- Configure `REVERSED_CLIENT_ID` in `Info.plist` for Google Sign-In.

---

## 📜 Firestore Security Rules (Suggested)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() {
      return request.auth != null;
    }

    match /employees/{employeeId} {
      allow read, write: if signedIn();
    }

    match /users/{userId} {
      allow read, write: if signedIn() && request.auth.uid == userId;
    }
  }
}
```

---

## 🚀 Execution

```bash
flutter pub get
flutter run
```

---

## 🤝 Contribution
Developed as a midterm project for **LTDNT**. Feel free to fork and enhance!

---
*Created with ❤️ by [thanhtrucne](https://github.com/thanhtrucne)*
