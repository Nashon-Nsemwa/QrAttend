# QR Attend - Project Documentation

QR Attend is a digital attendance management system that leverages QR code technology to simplify and secure the process of tracking student and lecturer attendance in academic institutions. The system is designed with a mobile-first approach using Flutter and Firebase.

> **Note:** This project is currently configured and tested for **Android only**. iOS support will be added in future updates.

---

## 📅 Download APK

You can download the latest version of the QR Attend Android app here: [Download APK](https://github.com/Nashon-Nsemwa/QrAttend/releases/download/New/app-release.apk)

> ⚠️ For testing purposes, use the following credentials:

### 👨‍🎓 Student

* **Reg No**: `bcs`
* **Password**: `123456`

### 👨‍🏫 Lecturer

* **Lecture ID**: `lec`
* **Password**: `123456`

---

## Badges

![Flutter](https://img.shields.io/badge/Flutter-Framework-blue)
![Firebase](https://img.shields.io/badge/Firebase-Backend-yellow)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Build](https://img.shields.io/github/workflow/status/yourusername/qr-attend/Flutter%20CI)

---

## Table of Contents

* [Project Overview](#project-overview)
* [Features](#features)
* [System Architecture](#system-architecture)
* [Screenshots](#screenshots)
* [Technologies Used](#technologies-used)
* [Modules](#modules)
* [Firestore Data Structure](#firestore-data-structure)
* [Setup and Installation](#setup-and-installation)
* [Firebase Configuration](#firebase-configuration)
* [API Documentation](#api-documentation)
* [Usage Guide](#usage-guide)
* [Deployment](#deployment)
* [Known Issues](#known-issues)
* [Future Improvements](#future-improvements)
* [License](#license)

---

## Project Overview

QR Attend streamlines attendance for students and lecturers by replacing manual sign-ins with QR code scanning. It helps institutions track attendance accurately and in real time, while ensuring data integrity with Firebase backend services.

---

## Features

* QR code-based attendance marking
* Role-based access (Student, Lecturer, Admin)
* Real-time notification system (using Firebase Cloud Messaging)
* Firestore integration for data storage
* User profile management
* Secure authentication with Firebase Auth
* **QR Expiration:** Lecturer can set a time limit for each QR code
* **GPS Validation:** Students must be within 100 meters of the lecturer when scanning
* **Smart Attendance Matching:** Time and location checks are done before recording attendance

---

## System Architecture

```
[ Flutter App ] <--> [ Firebase Auth ]
                       |
                       v
               [ Firestore Database ]
                       |
                       v
               [ Firebase Cloud Messaging ]
```

---

## Screenshots
> Replace the placeholders below with actual images from your app.

### Login Screens
![Signin Screens](Screenshots/Sign_in.png)

### Lecturer Dashboards
![Lecturer&student Dashboards](Screenshots/role_dashboards.png)

### Generate qr Screens
![Generate qr Screens](Screenshots/Generate_qr.png)

### QR Scan Screens
![QR Scan Screens](Screenshots/scan_qr.png)

### Attendance Screens
![Attendance Screens](Screenshots/attendance_data.png)

### Error on Scan Screens
![Error on scan Screens](Screenshots/Error_on_Scan.png)

---

## Technologies Used

* Flutter
* Firebase (Firestore, Auth, FCM, Storage)
* GetX (State management and routing)
* GetStorage (Local data persistence)

---

## Modules

### Authentication

* Email/password login
* Forgot password support
* Role verification (student, lecturer)

### User Management

* Register students and lecturers
* Update lecturer profile (name, email)
* Store student data with UID references

### QR Code Generation and Scanning

* Lecturers generate QR codes for their classes
* Students scan QR code to mark attendance
* QR includes expiration time
* Student location checked (within 100 meters of lecturer)

### Attendance Logging

* Attendance is stored with metadata (timestamp, lecture ID, student ID)
* Firestore structure optimized for performance

### Notifications

* Firebase Cloud Messaging is used
* Notifications are sent to user devices (e.g., schedule changes)
* Migration from `sendMulticast` to `sendEachForMulticast` (as per Firebase recommendation)

---

## Firestore Data Structure

```json
lectures: {
  lectureId: {
    name: "...",
    email: "...",
    department: "...",
    courses: ["..."],
    modules: ["..."],
    profileImagePath: "..."
  }
}

students: {
  studentId: {
    name: "...",
    email: "...",
    classId: "...",
    enrolledCourses: ["..."]
  }
}

attendance: {
  attendanceId: {
    studentId: "...",
    lectureId: "...",
    timestamp: "..."
  }
}

courses/{courseId}/modules/{moduleId}/attendance_summary/{studentId}: {
  attended: 3,
  totalClasses: 6,
  percentage: 50,
  lastUpdated: <timestamp>,
  name: "Nashon Nsemwa"
}
```

---

## Setup and Installation

1. Clone the repo:

   ```bash
   git clone https://github.com/yourusername/qr-attend.git
   ```
2. Open in VSCode or Android Studio.
3. Run `flutter pub get` to install dependencies.
4. Configure your Firebase project (see below).
5. Run the app:

   ```bash
   flutter run
   ```

---

## Firebase Configuration

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
2. Add an **Android app** to your project.
3. Download and place `google-services.json` into `android/app`.
4. Enable the following services in Firebase Console:

   * **Authentication:** Enable Email/Password login
   * **Firestore Database:** Set up rules and structure
   * **Firebase Cloud Messaging:** Set up FCM for notifications
   * **Storage:** Optional, for user profile image uploads
5. Set Firestore rules for proper read/write permissions.

---

## API Documentation

Currently, QR Attend uses Firebase SDKs and does not expose a custom REST API. Key interactions are through Firebase services:

### Authentication

* `FirebaseAuth.instance.signInWithEmailAndPassword(email, password)`
* `FirebaseAuth.instance.sendPasswordResetEmail(email)`

### Firestore Reads/Writes

* `FirebaseFirestore.instance.collection('lectures').doc(lectureId).set({...})`
* `FirebaseFirestore.instance.collection('attendance').add({...})`

### FCM Notifications

* Use Firebase Admin SDK to send push notifications:

```ts
await messaging.sendEachForMulticast({
  tokens: userTokens,
  notification: {
    title: 'Class Reminder',
    body: 'Don’t forget to attend your lecture today!'
  },
});
```

---

## Usage Guide

* **Lecturer:** Logs in → Generates QR → Shares with class
* **Student:** Logs in → Scans QR → Attendance marked
* **Admin:** Can view logs, manage users

---

## Deployment

* Use Firebase Hosting (optional for admin dashboard)
* Android build is deployable via Play Store
* CI/CD with GitHub Actions (if configured)

---

## Known Issues

* Firebase Cloud Messaging not supported on all emulators
* Delay in Firestore sync in poor internet conditions
* Offline support pending

---

## Future Improvements

* Offline scanning and sync later
* Analytics dashboard for attendance trends
* Role-based dashboard UI enhancements
* Add email verification
* iOS configuration and support

---

## License

MIT License. See `LICENSE` file for details.
