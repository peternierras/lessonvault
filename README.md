# LessonVault 📚
**A Mobile-Based Learning Material Repository for the College Classroom**

## Overview

LessonVault is a Flutter app with three user roles (Admin, Instructor, Student) backed by Firebase.

---

## What's implemented (~40% of full system)

| Feature | Status |
|---|---|
| Login screen (username + password) | ✅ Complete |
| Role-based routing (Admin / Instructor / Student) | ✅ Complete |
| Firebase Auth + Firestore user profiles | ✅ Complete |
| Instructor dashboard with classroom list | ✅ Complete |
| Create classroom + auto-generate class code | ✅ Complete |
| Classroom detail screen (materials tab) | ✅ Complete |
| Upload material (PDF, PPTX, MP4) with progress | ✅ Complete |
| Auto timestamp on each material upload | ✅ Complete |
| Auto push notification trigger on upload (via Cloud Functions) | ✅ Complete |
| Student dashboard with classroom list | ✅ Complete |
| Student join classroom via class code | ✅ Complete |
| Student view materials | ✅ Complete |
| Admin overview dashboard | ✅ Complete |
| FCM notification service (subscribe/unsubscribe) | ✅ Complete |

**Remaining to build:**
- Admin: full user management CRUD
- Instructor/Admin: announcement posting UI
- Material edit screen
- Material download + open file
- Notification history screen
- Admin: system settings screen

---

## Setup

### Prerequisites
- Flutter SDK 3.x
- Firebase project (Blaze plan for Cloud Functions + Storage)

### 1. Create Firebase project
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create a project
3. Enable **Authentication** (Email/Password), **Firestore**, **Storage**, **Cloud Messaging**

### 2. Add Firebase to the app
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 3. Firestore rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth.uid == userId || isAdmin();
      allow write: if isAdmin();
    }
    match /classrooms/{classroomId} {
      allow read: if request.auth != null;
      allow create, update, delete: if isInstructor() || isAdmin();
    }
    match /materials/{materialId} {
      allow read: if request.auth != null;
      allow create, update, delete: if isInstructor() || isAdmin();
    }
    match /announcements/{id} {
      allow read: if request.auth != null;
      allow write: if isInstructor() || isAdmin();
    }
    match /notification_triggers/{id} {
      allow create: if isInstructor() || isAdmin();
      allow read, delete: if false; // Cloud Functions only
    }

    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    function isInstructor() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'instructor';
    }
  }
}
```

### 4. Cloud Function (auto-notification on upload)
In `/functions/index.js`:
```javascript
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendMaterialNotification = functions.firestore
  .document("notification_triggers/{triggerId}")
  .onCreate(async (snap) => {
    const { topic, title, body } = snap.data();
    await admin.messaging().sendToTopic(topic, {
      notification: { title, body },
      data: { type: "new_material" },
    });
    await snap.ref.delete();
  });
```

### 5. Create admin account
In Firestore, create a document under `users/{uid}`:
```json
{
  "username": "admin",
  "email": "admin@yourdomain.com",
  "role": "admin",
  "fullName": "System Admin",
  "createdAt": "<timestamp>",
  "isActive": true
}
```

### 6. Run the app
```bash
flutter pub get
flutter run
```

---

## Project structure

```
lib/
  main.dart              # Entry point, theme, AuthWrapper
  models/
    user_model.dart      # UserModel + UserRole enum
    classroom_model.dart # ClassroomModel with classCode
    material_model.dart  # MaterialModel with timestamps
    announcement_model.dart
  services/
    auth_service.dart    # Firebase Auth + Firestore user profile
    classroom_service.dart  # CRUD for classrooms, materials, announcements
    storage_service.dart # Firebase Storage file uploads
    notification_service.dart # FCM setup, topic subscribe/unsubscribe
  screens/
    auth/login_screen.dart
    admin/admin_dashboard.dart
    instructor/
      instructor_dashboard.dart
      create_classroom_screen.dart
      classroom_detail_screen.dart
      upload_material_screen.dart
    student/
      student_dashboard.dart
      student_classroom_screen.dart
  utils/
    app_colors.dart      # Color palette + constants
```
