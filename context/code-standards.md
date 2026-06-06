```markdown
# Code Standards

## General

- Keep files small and single-purpose — one widget, one provider, or one DAO per file
- Fix root causes — do not add workarounds or conditional hacks
- Do not mix UI, business logic, and data access in the same file
- Prefer explicit over implicit — name things clearly after what they do

## Dart / Flutter

- Dart null safety is required throughout — no `!` force-unwrap without a comment explaining why it is safe
- Use `const` constructors wherever possible
- Avoid `dynamic` — use explicit types or generics
- All public classes, methods, and fields must have a brief doc comment if their purpose is not obvious
- Use `freezed` for immutable data models — no mutable model classes

## Riverpod

- All state lives in Riverpod providers — no `setState` outside of trivial local UI state
- Use `AsyncNotifierProvider` for anything that involves async data loading
- Keep providers focused — one provider per logical concern
- Never call a provider's notifier from inside another provider's build method

## Drift (Local DB)

- Table definitions live in `lib/core/db/tables/`
- DAOs live in `lib/core/db/daos/` — one DAO per feature domain
- Never write raw SQL strings — use Drift's type-safe query API
- All queries must filter by `userId` — never query without a user scope

## Firebase / Firestore

- Firestore access is only permitted inside `lib/core/sync/`
- No Firestore calls from feature code or UI — always go through the sync service
- All Firestore documents must have a `userId` field and `updatedAt` timestamp
- Security rules must enforce userId matching — test rules before deploying

## Validation Rules (Business Logic)

- Total allocations for a period ≤ total income for that period — enforce in AllocationNotifier
- Transaction amount ≤ remaining category balance — enforce in TransactionNotifier
- Budget period end date must be after start date — enforce in PeriodNotifier
- These rules throw a typed `BudgetException` — never silently ignore violations

## Navigation

- All routes are defined in `lib/core/router/app_router.dart`
- Use named routes only — no anonymous `MaterialPageRoute`
- Auth guard is applied at the router level — no manual auth checks in screens

## File Organization

- `lib/features/<feature>/` — screens, widgets, and providers for each feature
- `lib/features/<feature>/screens/` — full-page screen widgets
- `lib/features/<feature>/widgets/` — smaller widgets used within the feature
- `lib/features/<feature>/providers/` — Riverpod providers for the feature
- `lib/core/db/` — Drift database, tables, DAOs
- `lib/core/sync/` — Firebase sync service
- `lib/core/router/` — go_router configuration
- `lib/core/theme/` — ThemeData, color tokens, text styles
- `lib/core/widgets/` — shared reusable widgets used across features
- `lib/core/exceptions/` — typed exception classes

```
