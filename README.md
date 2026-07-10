# ProofBoard

ProofBoard is a cross-platform Flutter app for turning small daily work into a visible proof-of-work portfolio.

It is built for students, beginners, self-learners, and student-builders who want to track practice sessions across skills like coding, CAD, studying, deep work, exercise, reading, sleep, and other personal goals. Each proof records what you did, how long you spent, which skill it belongs to, and a short note.

ProofBoard is intentionally local-first for version 1: no login, no backend, no Firebase, and no paid APIs. Proofs, skills, theme preference, and mode preference are stored on the device with `shared_preferences`.

## Features

- Home dashboard with streak, total proofs, total minutes, recent proofs, suggested skills, and helpful resources.
- Custom skills with editable names, colors, icons, and skill modes.
- Skill modes for General, Productivity, and Self-Improvement tracking.
- Animated mode switching with mode-specific colors and app personality.
- Calendar screen with colored skill dots for days that have proofs.
- Calendar filter for all proofs or current-mode proofs only.
- Add, edit, and delete proofs.
- Timeline screen with reverse chronological proof cards.
- Stats dashboard with totals, streak, active skills, best skill, and skill breakdown progress bars.
- Weekly recap and copyable portfolio-style summary.
- Settings screen for appearance, mode, skill management, local data, and app info.
- Light mode, dark mode, and system theme support.
- Local persistence with `shared_preferences`.

## Tech Stack

- Flutter
- Dart
- Material 3
- `provider` with `ChangeNotifier` for beginner-friendly state management
- `shared_preferences` for local persistence
- Flutter built-in Clipboard APIs for copying summaries and resource links

ProofBoard targets Android and iOS. Android can be tested from Windows after installing Android Studio and the Android SDK. iOS can be built later from macOS with Xcode.

## Screenshots

Screenshots should be added as the UI stabilizes.

Suggested screenshots:

- Home dashboard in General Mode
- Productivity Mode activation animation
- Add/Edit Proof form
- Timeline with proof cards
- Calendar with skill dots
- Stats dashboard
- Settings mode selector
- Dark mode view

Recommended folder:

```text
docs/screenshots/
```

Then link screenshots here with Markdown image tags.

## How To Run The App

### 1. Install Flutter

Follow the official Flutter setup guide for Windows:

```text
https://docs.flutter.dev/get-started/install/windows/mobile
```

Check Flutter from the terminal:

```powershell
flutter --version
```

If Flutter is installed but not on your PATH, run it with the full path or add Flutter's `bin` folder to PATH. In this project, Flutter has been used from:

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

### 5. Run Tests

```powershell
flutter test
```

### 6. Run The App

Start an Android emulator or connect an Android phone with USB debugging enabled, then run:

```powershell
flutter devices
flutter run
```

## Current Status

ProofBoard is a polished local-first MVP.

Working now:

- Cross-platform Flutter project structure
- Android and iOS platform folders
- Home dashboard
- Add/Edit Proof form
- Delete proof confirmation
- Timeline
- Stats dashboard
- Calendar with skill dots
- Custom skills with custom colors
- Manage Skills screen
- General, Productivity, and Self-Improvement modes
- Animated mode switching
- Mode preference persistence
- Light/dark/system theme support
- Theme preference persistence
- Weekly recap generation
- Copyable share summary
- Local proof and skill storage with `shared_preferences`
- Clear all proof data from Settings

Known setup notes:

- iOS cannot be built on Windows. The iOS project files are kept compatible for later use on a Mac with Xcode.
- Android testing on Windows requires Android Studio, Android SDK, and either an emulator or physical Android device.
- No backend or account sync exists yet by design.

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

- `lib/main.dart` - app startup, providers, bottom navigation, and mode animation shell
- `lib/models/proof.dart` - the Proof data model
- `lib/models/skill.dart` - custom Skill model and starter skills
- `lib/models/app_mode.dart` - app mode enum and mode labels
- `lib/controllers/proof_controller.dart` - proof state and add/edit/delete logic
- `lib/controllers/skill_controller.dart` - skill state and local skill updates
- `lib/controllers/settings_controller.dart` - theme and app mode preferences
- `lib/services/proof_storage_service.dart` - local proof persistence
- `lib/screens/add_proof_screen.dart` - form validation and saving a proof
- `lib/screens/calendar_screen.dart` - calendar activity view with skill dots

## Next Planned Features

- Timeline filtering by skill and mode.
- Search proofs by title, note, or skill.
- Monthly recap generation.
- Better stats for minutes by skill, longest streak, and average minutes per proof.
- Optional local display name for exported summaries.
- App icon and launch screen polish.
- More widget tests for add/edit/delete, mode switching, and skill management.

## Documentation

Project planning and learning notes live in:

- `docs/ROADMAP.md`
- `docs/DEVLOG.md`
- `docs/PROMPTS.md`
- `docs/DECISIONS.md`
