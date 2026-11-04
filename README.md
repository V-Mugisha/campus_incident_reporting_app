# Campus Incident Reporting App

A Flutter mobile application that lets students report campus issues - broken
facilities, water shortages, electricity outages, damaged furniture, sanitation
problems, and safety concerns - and track their resolution.

## Features
- Submit incident reports with category, description, and optional photo
- Browse, search, and filter submitted reports
- View report details and track status through to resolution
- Role-based access: students submit and browse; authorized staff review and update status

## Tech stack
- Flutter (Dart)
- Firebase Authentication
- Cloud Firestore
- Firebase Storage (incident photos)
- Provider (state management)

## Getting started
1. `flutter pub get`
2. Connect a Firebase project (`flutterfire configure`) to generate Firebase options
3. Run on an emulator or physical device: `flutter run`

> Note: this app targets Android/iOS; it is not intended to run in a browser.
