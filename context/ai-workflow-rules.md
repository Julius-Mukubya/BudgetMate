# AI Workflow Rules

## Approach

Build this project incrementally using a spec-driven workflow. The context
files define what to build, how to build it, and the current state of progress.
Always implement against these specs — do not infer or invent behavior not
defined here.

## Scoping Rules

- Work on one feature unit at a time
- Prefer small, verifiable increments over large speculative changes
- Do not combine unrelated system boundaries in a single implementation step

## Feature Build Order

Follow this sequence — do not skip ahead:

1. Project setup (Flutter project, dependencies, folder structure)
2. Core theme and design tokens
3. Drift database schema and DAOs
4. Firebase Auth integration (sign up, login, logout)
5. Budget period feature (create, list)
6. Income feature (record income per period)
7. Budget plan feature (categories + planned amounts)
8. Allocation feature (allocate income to categories)
9. Transaction feature (record spend against a category)
10. Dashboard screen (aggregated period view)
11. Variance screen (planned vs actual per category, with color coding and sorting)
12. History screen (past periods)
13. Firebase sync service (offline → online sync)

## When to Split Work

Split an implementation step if it combines:

- UI changes and database schema changes
- Multiple unrelated features
- Behavior not clearly defined in the context files

If a change cannot be verified end to end quickly, the scope is too broad — split it.

## Handling Missing Requirements

- Do not invent product behavior not defined in the context files
- If a requirement is ambiguous, resolve it in the relevant context file before implementing
- If a requirement is missing, add it as an open question in `progress-tracker.md`
  before continuing

## Protected Files

Do not modify the following unless explicitly instructed:

- `lib/core/db/database.dart` — the root Drift database definition (schema changes
  require a migration, not a rewrite)
- Any generated `.g.dart` or `.freezed.dart` files — these are code-gen outputs,
  regenerate with `flutter pub run build_runner build`

## Keeping Docs in Sync

Update the relevant context file whenever implementation changes affect:

- System architecture or data model
- New invariants or validation rules
- Code conventions or standards
- Feature scope (additions or removals)

## Before Moving to the Next Unit

1. The current unit works end to end within its defined scope
2. No invariant defined in `architecture.md` was violated
3. `progress-tracker.md` reflects the completed work
4. `flutter analyze` passes with no errors
5. `flutter build apk --debug` completes without errors
