# ProofBoard Roadmap

This roadmap keeps the project focused and beginner-friendly. The goal is to build ProofBoard step by step without adding a backend or unnecessary complexity too early.

## Version 1: MVP

Status: In progress, core app built.

Included:

- Home dashboard
- Add Proof form
- Timeline
- Stats screen
- Weekly recap
- Copy recap to clipboard
- Local persistence with `shared_preferences`
- Android and iOS Flutter project folders

Definition of done:

- App runs on Android emulator or Android phone.
- `flutter analyze` passes.
- A user can add, view, delete, and persist proofs locally.
- Empty states are friendly and clear.

## Version 1.1: Usability Improvements

Planned:

- Edit an existing proof.
- Filter Timeline by category.
- Add search by proof title or note.
- Improve form keyboard behavior.
- Add more helpful empty states after deleting all proofs.

Why this matters:

These features make the app easier to use every day without changing the basic architecture.

## Version 1.2: Better Stats

Planned:

- Monthly totals.
- Longest streak.
- Average minutes per proof.
- Category minutes, not only category proof counts.
- A simple calendar-style activity view.

Why this matters:

ProofBoard should help users see consistency, not just store entries.

## Version 1.3: Portfolio Polish

Planned:

- Better share text templates.
- Export weekly or monthly summary text.
- Optional user display name stored locally.
- App icon and launch screen polish.
- Screenshot-ready sample data mode for demos.

Why this matters:

The app idea is connected to building a visible proof-of-work habit, so sharing and presentation should feel strong.

## Later Ideas

These are not planned for the MVP:

- Cloud sync
- Login
- Firebase
- Image uploads
- Public profiles
- AI-generated recaps

These may be useful later, but adding them too early would make the first version harder to learn, test, and finish.
