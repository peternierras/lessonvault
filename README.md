# LessonVault 📚
**A Mobile-Based Learning Material Repository for the College Classroom**

## Overview

LessonVault is a cross-platform educational application developed using Flutter for Android and Windows. It serves as a centralized repository for managing and distributing learning materials in college classrooms. The system enables instructors to upload course resources, post announcements, and organize classrooms by year level, while students can join classes using unique class codes and access instructional materials anytime and anywhere.

The application uses :contentReference[oaicite:0]{index=0} as its backend for user authentication, PostgreSQL database management, cloud file storage, and real-time synchronization. LessonVault supports three user roles: Administrator, Instructor, and Student, each with role-based access and specific functionalities.

---

## Key Features

### Authentication and User Roles
- Secure login and registration
- Role-based access control (Admin, Instructor, Student)
- Automatic routing to role-specific dashboards

### Classroom Management
- Create and manage classrooms
- Automatically generate unique class codes
- Organize classrooms into:
  - 1st Year Classrooms
  - 2nd Year Classrooms
  - 3rd Year Classrooms
  - 4th Year Classrooms
- Students can join classrooms using class codes

### Learning Material Repository
- Upload course materials (PDF, PPTX, DOCX, MP4, and more)
- Cloud-based file storage
- Download and open materials on supported devices
- Automatic upload timestamps

### Announcements
- Create classroom-specific announcements
- Edit and delete announcements
- Real-time updates for all enrolled students
- Role-based permissions (only Admins and Instructors can manage announcements)

### Notifications
- Local notifications when new announcements are posted

### Administrative Tools
- View all classrooms
- Monitor platform usage and data

---

## Technology Stack

### Frontend
- :contentReference[oaicite:1]{index=1}
- :contentReference[oaicite:2]{index=2}

### Backend
- :contentReference[oaicite:3]{index=3}
  - Authentication
  - PostgreSQL Database
  - Storage
  - Real-time Streams

### State Management
- :contentReference[oaicite:4]{index=4}

### Additional Packages
- :contentReference[oaicite:5]{index=5}
- :contentReference[oaicite:6]{index=6}
- :contentReference[oaicite:7]{index=7}
- :contentReference[oaicite:8]{index=8}
- :contentReference[oaicite:9]{index=9}
- :contentReference[oaicite:10]{index=10}

---

## Supported Platforms

- Android
- Windows Desktop

---

## Current Implementation Status

| Module | Status |
|------|------|
| Authentication | ✅ Complete |
| Role-Based Dashboards | ✅ Complete |
| Classroom Management | ✅ Complete |
| Year-Level Categorization | ✅ Complete |
| Material Upload and Download | ✅ Complete |
| Announcements (Create/View/Edit/Delete) | ✅ Complete |
| Local Notifications | ✅ Complete |
| Windows Deployment | ✅ Complete |
| Android Deployment | ✅ Complete |
| Push Notifications (FCM) | ⏳ Planned |

---

## Installation

### Prerequisites
- Flutter SDK 3.x
- Android Studio
- Visual Studio Community 2022 (Desktop development with C++)
- Supabase project

### Clone the Repository
```bash
git clone https://github.com/your-username/lessonvault.git
cd lessonvault