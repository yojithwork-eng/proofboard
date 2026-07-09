# ProofBoard

ProofBoard is a cross-platform Flutter app for logging small daily "proofs of work" while building skills.

It is designed for students, beginners, and self-learners who want a simple way to track what they practiced, how much time they spent, and which skill category they worked on. Over time, ProofBoard becomes a lightweight visual timeline of progress.

This project is intentionally simple: no login, no backend, no Firebase, and no paid APIs. All proof data is stored locally on the device.

## Features

- Home dashboard with today's date, current streak, total proofs, and total minutes.
- Category summary cards for areas like Coding, CAD, Robotics, Gym, Studying, Networking, Reading, and Other.
- Add Proof form with validation for title, category, and minutes.
- Timeline screen showing all proofs in reverse chronological order.
- Delete proof flow with a confirmation dialog.
- Stats screen with total proofs, total minutes, active categories, current streak, and best category.
- Category breakdown with simple progress bars.
- Local weekly recap generator.
- Copyable portfolio-style recap using Flutter's built-in clipboard support.
- Polished empty states for first-time users.
- Local persistence with `shared_preferences`.

## Tech Stack

- Flutter
- Dart
- Material 3
- `shared_preferences` for local device storage
- `provider` with `ChangeNotifier` for simple state management

ProofBoard currently targets Android and iOS. Android can be tested from Windows after installing Android Studio and the Android SDK. iOS can be built later from macOS with Xcode.

## Screenshots

Screenshots will be added as the app UI stabilizes.

Suggested screenshots to capture later:

- Home dashboard
- Add Proof form
- Timeline with proof cards
- Stats screen with category progress
- Weekly recap modal

Place screenshots in a future folder such as:

```text
docs/screenshots/
```

Then link them here using Markdown image tags.

## How To Run The App

### 1. Install Flutter

Follow the official Flutter setup guide for Windows:

```text
https://docs.flutter.dev/get-started/install/windows/mobile
```

Make sure Flutter is available from your terminal:

```powershell
flutter --version
```

If Flutter is installed but not on your PATH, run it with the full path or add Flutter's `bin` folder to PATH. In this project, Flutter was found at:

```powershell
C:\Users\ymedu\flutter\bin
```

### 2. Install Android Studio And Android SDK

On Windows, Android testing requires Android Studio and the Android SDK.

After installing Android Studio, run:

```powershell
flutter doctor
```

Fix any Android toolchain issues it reports.

### 3. Get Packages

From the project root:

```powershell
flutter pub get
```

### 4. Analyze The Code

```powershell
flutter analyze
```

### 5. Run The App

Start an Android emulator or connect an Android phone with USB debugging enabled, then run:

```powershell
flutter devices
flutter run
```

## Current Status

ProofBoard is at MVP stage.

Working now:

- Flutter project setup
- Android platform folder
- iOS platform folder
- Home screen
- Add Proof screen
- Timeline screen
- Stats screen
- Local storage
- Weekly recap generation
- Copy to clipboard
- Delete proof confirmation
- Clean analyzer result

Known setup note:

- iOS cannot be built on Windows. The existing iOS project files are ready for later use on a Mac with Xcode.
- Android cannot run until Android Studio and the Android SDK are installed.

## Project Structure

```text
lib/
  main.dart
  app_theme.dart
  constants/
  controllers/
  models/
  screens/
  services/
  utils/
  widgets/
docs/
  ROADMAP.md
  DEVLOG.md
  PROMPTS.md
  DECISIONS.md
```

Good files to read first:

- `lib/main.dart` - app startup and bottom navigation
- `lib/models/proof.dart` - the Proof data model and category enum
- `lib/controllers/proof_controller.dart` - app state and add/delete logic
- `lib/services/proof_storage_service.dart` - local storage with shared preferences
- `lib/screens/add_proof_screen.dart` - form validation and saving a proof

## Next Planned Features

- Edit an existing proof.
- Add filter chips on Timeline by category.
- Add simple search for proof titles and notes.
- Add monthly stats.
- Add export/share options for portfolio summaries.
- Improve app icon and launch screen branding.
- Add more widget tests for add/delete flows.

## Documentation

Project planning and learning notes live in:

- `docs/ROADMAP.md`
- `docs/DEVLOG.md`
- `docs/PROMPTS.md`
- `docs/DECISIONS.md`
