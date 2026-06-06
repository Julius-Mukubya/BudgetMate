# Progress Tracker

Update this file after every meaningful implementation change.

## Current Phase

Not started

## Current Goal

Project setup — Flutter project scaffold, dependencies, folder structure,
and core theme.

## Completed

- None yet.

## In Progress

- None yet.

## Next Up

1. Flutter project setup with correct folder structure and pubspec.yaml dependencies
2. Core theme (ThemeData, color tokens, typography) in `lib/core/theme/`
3. Drift database schema (all 5 tables) and DAOs
4. Firebase Auth integration (sign up, login, logout screens)

## Open Questions

- What currency does the primary user use? (App is single-currency per user in v1 —
  confirm whether currency should be selectable at account setup or hardcoded)
- Should a budget period allow multiple income entries or just one salary entry?
  (Currently specced as multiple — confirm)
- Should deleting a category also delete its allocations and transactions,
  or block deletion if transactions exist?

## Architecture Decisions

- **Offline-first with Drift**: Local SQLite via Drift is the UI source of truth.
  Firestore is a sync target, not a read source. This simplifies offline behavior
  and avoids loading spinners for local data.
- **Riverpod for state**: Chosen over Bloc for less boilerplate and better fit
  with Drift's stream-based query API.
- **Freezed for models**: All data models are immutable Freezed classes to prevent
  accidental mutation and simplify equality checks.
- **Allocation as a separate step from planning**: Plan = intent, Allocation = committed
  funds. This lets users plan loosely and allocate precisely before the period starts.

## Session Notes

- Context files are complete and ready for implementation to begin
- Start with `flutter create` and immediately restructure folders to match
  the layout in `code-standards.md`
- Add all dependencies to `pubspec.yaml` before writing any feature code
