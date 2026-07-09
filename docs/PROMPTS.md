# ProofBoard Prompts

This file stores useful prompts used to shape the project. Keeping prompts is helpful because it shows the thinking behind the app and makes it easier to continue development later.

## Original MVP Prompt Summary

Goal:

Build a cross-platform Flutter app called ProofBoard for students and beginners to log small daily proofs of work.

Important constraints:

- Use Flutter and Dart.
- Use Material 3.
- Use `shared_preferences` for local persistence.
- No backend.
- No login or authentication.
- No Firebase.
- No paid APIs.
- Keep code beginner-friendly.

Main features requested:

- Home dashboard
- Add Proof form
- Timeline
- Stats
- Weekly recap
- Copy recap to clipboard
- Delete proof confirmation
- Local persistence

## Useful Future Prompt: Edit Proof

```text
Add an Edit Proof feature to ProofBoard.
Keep the app Flutter-only and local-only.
Do not add a backend, authentication, or Firebase.
Use the existing Proof model, ProofController, and shared_preferences storage.
Add the minimum code needed so a user can edit title, category, minutes, and note for an existing proof.
Keep the UI consistent with the current Add Proof screen.
Run flutter analyze after making changes.
```

## Useful Future Prompt: Timeline Filters

```text
Add category filters to the Timeline screen.
Use chips or segmented controls.
Keep all data local.
Do not redesign the whole app.
The user should be able to view all proofs or only proofs from one category.
Keep the code beginner-friendly.
```

## Useful Future Prompt: Better Stats

```text
Improve the Stats screen for ProofBoard.
Add monthly totals, longest streak, and category minutes.
Keep Provider and ChangeNotifier.
Do not add charts packages unless absolutely necessary.
Use simple Material 3 widgets and progress bars.
Run flutter analyze.
```

## Useful Future Prompt: Portfolio Export

```text
Add a stronger portfolio summary feature to ProofBoard.
Generate a copyable monthly recap from local data only.
Do not use AI or external APIs.
Keep the existing weekly recap.
Add clear empty states for users with no data.
```

## Prompting Notes For This Project

Good prompts for ProofBoard should mention:

- Keep Flutter.
- Keep Android and iOS compatibility.
- Keep storage local.
- Keep the code beginner-friendly.
- Avoid backend/auth unless explicitly planned.
- Make small changes and run `flutter analyze`.
