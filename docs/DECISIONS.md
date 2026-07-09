# ProofBoard Decisions

This file records important technical and product decisions. The goal is to make the project easier to understand later.

## Decision: Use Flutter

ProofBoard is a cross-platform mobile app, so Flutter lets one Dart codebase target both Android and iOS.

Reason:

- Good for beginner mobile development.
- Strong Material design support.
- Works for Android now and iOS later.
- Avoids maintaining separate native apps.

## Decision: Use Material 3

ProofBoard uses Material 3 for the visual style.

Reason:

- Modern Flutter default.
- Clean mobile components.
- Good support for navigation bars, cards, forms, buttons, and dialogs.

## Decision: No Backend In Version 1

ProofBoard stores data only on the device.

Reason:

- Keeps the MVP simple.
- Avoids login and account management.
- Avoids server costs.
- Makes the app easier to understand for a beginner.

Tradeoff:

- Data does not sync across devices yet.
- If the app is deleted, local data may be lost.

## Decision: Use shared_preferences

Proofs are stored as encoded JSON in `shared_preferences`.

Reason:

- Simple dependency.
- Good enough for a small MVP.
- Easy for a beginner to inspect and understand.

Tradeoff:

- Not ideal for large or complex databases.
- A future version may move to SQLite or another local database if the app grows.

## Decision: Use Provider And ChangeNotifier

ProofBoard uses `Provider` with a `ProofController` that extends `ChangeNotifier`.

Reason:

- Beginner-friendly state management.
- Small amount of boilerplate.
- Screens update immediately after adding or deleting a proof.

Tradeoff:

- Larger apps may eventually need a more structured architecture.

## Decision: Keep Recaps Local

Weekly recap text is generated from local proof data only.

Reason:

- No paid APIs.
- No privacy concerns.
- Works offline.
- Keeps the MVP simple.

## Decision: Keep iOS Compatibility

Even though development is currently on Windows, the project includes iOS platform files and avoids Android-only Dart code.

Reason:

- The app should be ready to open on a Mac later.
- Most ProofBoard logic lives in shared Flutter/Dart code.

Important note:

- iOS still requires macOS and Xcode to build or run.

## Decision: Do Not Add Firebase Yet

Firebase is intentionally not part of version 1.

Reason:

- No login is needed.
- No cloud sync is needed for the MVP.
- Avoids extra setup while learning Flutter basics.

This can be reconsidered later only if the product needs accounts, sync, or cloud backup.
