# ProofBoard Roadmap

This roadmap keeps ProofBoard focused, beginner-friendly, and local-first. The app should grow step by step without adding a backend or account system before the core habit-tracking experience feels strong.

## Version 1.0: Local-First MVP

Status: Built and being polished.

Included:

- Home dashboard
- Add, edit, and delete proofs
- Timeline
- Stats dashboard
- Weekly recap
- Copyable share summary
- Custom skills with custom colors
- Manage Skills screen
- Calendar with colored skill dots
- Light, dark, and system theme support
- Settings screen
- Local proof, skill, theme, and mode persistence with `shared_preferences`
- General, Productivity, and Self-Improvement modes
- Animated mode switching
- Static helpful resources by mode
- Android and iOS Flutter project folders

Definition of done:

- App runs on Android emulator or Android phone.
- `flutter analyze` passes.
- Existing widget tests pass.
- A user can add, edit, view, delete, and persist proofs locally.
- A user can create and manage custom skills.
- Calendar highlights proof activity with skill colors.
- Mode switching works and persists after restart.
- Empty states are friendly and clear.

## Version 1.1: Daily Use Improvements

Planned:

- Filter Timeline by skill.
- Filter Timeline by app mode.
- Search proofs by title, note, or skill.
- Add quick date picker support for backfilling a proof.
- Improve form keyboard flow on smaller phones.
- Add more widget tests for add/edit/delete proof flows.

Why this matters:

These features make ProofBoard easier to use every day without changing the local-first architecture.

## Version 1.2: Stronger Analytics

Planned:

- Monthly recap generation.
- Longest streak.
- Average minutes per proof.
- Minutes by skill, not only proof counts by skill.
- Most active day of the week.
- Calendar month summary improvements.
- Stats filters for all modes or current mode only.

Why this matters:

ProofBoard should help users understand consistency, focus, and momentum over time.

## Version 1.3: Portfolio Polish

Planned:

- More share text templates.
- Weekly and monthly export options.
- Optional local display name stored on device.
- Screenshot-ready sample data mode for demos.
- App icon and launch screen polish.
- Better onboarding for first-time users.

Why this matters:

ProofBoard is meant to help students turn small work into visible proof, so exporting and presentation should feel polished.

## Version 1.4: Mode Expansion

Planned:

- Mode-specific dashboards.
- Mode-specific suggested proof prompts.
- Mode-aware stats and calendar defaults.
- Better resource organization by skill and mode.
- Optional skill templates for common goals like exam prep, job search, fitness, and portfolio building.

Why this matters:

The mode system is now in place. Future versions can make each mode feel more useful without creating separate apps.

## Later Ideas

These are not planned for the current local-first MVP:

- Cloud sync
- Login
- Firebase
- Image uploads
- Public profiles
- AI-generated recaps
- Paid APIs

These may be useful later, but adding them too early would make ProofBoard harder to learn, test, and finish.
