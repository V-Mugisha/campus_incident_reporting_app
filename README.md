# CampusCare (Campus Incident Reporting App)

A Flutter mobile app where students report campus issues (facilities, water,
electricity, safety, sanitation) and authorized staff review and update their
status.

## Prerequisites

Make sure the following are installed and working before you start:

- **Git**, to clone the repository.
- **Flutter SDK** (3.47.x or later, Dart SDK `^3.13.7`), installed and on your
  `PATH`. Verify with `flutter --version`.
- **Android Studio** (recommended) with an **Android emulator** configured, or
  a physical Android device connected. Xcode and an iOS simulator also work,
  though this app is primarily tested on Android.
- A running emulator/simulator or a connected device.

## Getting started

1. Clone the repository:

   ```
   git clone https://github.com/V-Mugisha/campus_incident_reporting_app.git
   ```

2. Move into the project directory:

   ```
   cd campus_incident_reporting_app
   ```

3. Install the dependencies:

   ```
   flutter pub get
   ```

4. Start your Android emulator (or iOS simulator), or connect a physical device.

5. Run the app:

   ```
   flutter run
   ```

No Firebase setup is required: this repository is already wired to the Firebase
project `campus-incident-reportin-3ea44`, and all Firebase config is committed.

## Demo accounts

The login screen has "Staff User Mock" and "Student User Mock" buttons that
autofill the form. You can also type the credentials manually:

- Staff: `staff@alueducation.com` / `Campus123`
- Student: `m.victor@alustudent.com` / `Campus123`

Both accounts already exist in the Firebase project. Only ALU addresses are
accepted: students use `@alustudent.com`, staff use `@alueducation.com`.

## Features

- Sign up and log in with email and password (Firebase Authentication)
- Students: submit reports (category, title, description, location, optional
  photo), browse and filter their own reports, and track the status timeline
- Staff: review all reports, search and filter by status, and update the status
  (start progress / mark resolved / reopen)
- Role-based access: only staff can update statuses, enforced by both the UI and
  Firestore security rules

## Tech stack

- Flutter (Dart)
- Firebase Authentication and Cloud Firestore
- Provider (state management)

## Firebase configuration (already done)

- `lib/firebase_options.dart` and `android/app/google-services.json` are
  committed.
- Firestore security rules live in `firestore.rules` (deployed).
- A composite index on `incidents` (`reportedBy` asc + `createdAt` desc), needed
  by the "My Reports" screen, is defined in `firestore.indexes.json` and
  deployed.

### Reproducing the setup on a new Firebase project

If you point this code at a different Firebase project:

1. Create the project and enable Email/Password sign-in. In Auth settings,
   disable email enumeration protection.
2. Run `dart run tool/seed_demo_users.dart` before deploying rules, so the staff
   role can be written.
3. `firebase deploy --only firestore:rules,firestore:indexes`.
