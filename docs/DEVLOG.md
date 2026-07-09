# ProofBoard Devlog

This devlog records what has been built and what was learned along the way. It is written for a beginner developer who wants to understand the project history.

## 2026-07-09

Initial ProofBoard MVP created.

Built:

- Flutter app structure
- Material 3 theme
- `Proof` model
- `ProofCategory` enum
- Local persistence service using `shared_preferences`
- `ProofController` using `ChangeNotifier`
- Home screen
- Add Proof screen
- Timeline screen
- Stats screen
- Reusable widgets for proof cards, stat cards, category badges, empty states, and recap sheets

Important behavior:

- Proofs are saved locally.
- Proofs remain after the app restarts.
- Home, Timeline, and Stats update after adding or deleting a proof.
- Weekly recap text is generated locally without AI or an API.
- Recap text can be copied to the clipboard.

## Flutter Compatibility Fix

Issue:

The project hit this Flutter compile error:

```text
The argument type 'CardTheme' can't be assigned to the parameter type 'CardThemeData?'.
```

Fix:

Updated `lib/app_theme.dart` to use `CardThemeData`, which matches the current Flutter SDK.

Also updated newer Flutter deprecations:

- Replaced `withOpacity(...)` with `withValues(alpha: ...)`.
- Replaced deprecated dropdown `value:` usage with `initialValue:`.

Result:

```text
flutter analyze
No issues found.
```

## Mobile Platform Setup

Generated Android and iOS folders with:

```powershell
flutter create . --project-name proofboard --org com.yabro1010 --platforms android,ios
```

Result:

- Android project files exist.
- iOS project files exist.
- The app remains cross-platform.
- No Android-only app logic was added.

## Current Local Setup Notes

Flutter was found at:

```powershell
C:\Users\ymedu\flutter\bin
```

Android SDK is not installed yet, so Android running requires Android Studio setup first.

iOS builds require macOS and Xcode later.
