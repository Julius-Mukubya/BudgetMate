# Architecture Context

## Stack

| Layer          | Technology                        | Role                                          |
| -------------- | --------------------------------- | --------------------------------------------- |
| Framework      | Flutter (Dart)                    | Cross-platform mobile UI and app logic        |
| State Mgmt     | Riverpod                          | Reactive state management across the app      |
| Local Storage  | Drift (SQLite)                    | Offline-first local database                  |
| Remote Backend | Firebase (Firestore + Auth)       | Cloud sync, authentication, remote data store |
| Sync Layer     | Custom sync service               | Merges local and remote state when online     |
| Navigation     | go_router                         | Declarative routing                           |

## System Boundaries

- `lib/features/auth/` — Sign up, login, logout. Owns the current user session.
- `lib/features/periods/` — Budget period creation and listing. Owns the period model.
- `lib/features/income/` — Income entry recording per period. Owns the income model.
- `lib/features/plan/` — Expenditure category creation and planned amounts. Owns the plan and category models.
- `lib/features/allocation/` — Allocating funds from income to categories. Owns the allocation model.
- `lib/features/transactions/` — Recording actual spend transactions. Owns the transaction model.
- `lib/features/dashboard/` — Aggregated view of a period. Read-only derived state — owns no models.
- `lib/features/variance/` — Planned vs actual comparison view. Read-only derived state — aggregates Category planned amounts against Transaction totals per category.
- `lib/core/db/` — Drift database definition, DAOs, and table schemas.
- `lib/core/sync/` — Sync service that pushes local changes to Firestore and pulls remote changes.
- `lib/core/router/` — go_router route definitions and guards.

## Data Model

### BudgetPeriod
- id, userId, name, startDate, endDate, createdAt

### IncomeEntry
- id, periodId, userId, label, amount, date, createdAt

### Category
- id, periodId, userId, name, plannedAmount, createdAt

### Allocation
- id, categoryId, periodId, userId, amount, createdAt

### Transaction
- id, categoryId, periodId, userId, amount, date, note, createdAt

## Storage Model

- **Local (Drift / SQLite)**: All data is written locally first. This is the source
  of truth for the UI. Every record has a `syncedAt` nullable timestamp — null means
  pending sync.
- **Remote (Firestore)**: Mirrors local data per user. Collections are namespaced
  by userId. Used for cross-device access and backup.
- **Auth (Firebase Auth)**: Manages user identity. UID is the foreign key linking
  all Firestore documents to their owner.

## Auth and Access Model

- Every user authenticates via Firebase Auth (email + password in v1)
- On login, the local DB is scoped to that user's UID
- Every record stores a userId — queries always filter by the current user's UID
- On logout, local data is retained on device but the UI is gated behind auth
- Remote data in Firestore has security rules: users can only read/write their own documents

## Sync Model

- **Write path**: User action → write to local Drift DB → mark as unsynced →
  if online, sync service pushes to Firestore immediately
- **Read path (initial / resume)**: On app start or reconnect, sync service
  fetches remote records newer than the last sync timestamp and merges into local DB
- **Conflict resolution**: Last-write-wins based on `updatedAt` timestamp
- **Offline**: App functions entirely from local DB. Sync is opportunistic.

## Invariants

1. The UI always reads from the local Drift database — never directly from Firestore
2. Total allocations for a period must never exceed total income for that period
3. A transaction amount must not exceed the remaining balance of its category
4. All records are scoped to a userId — no cross-user data access is ever permitted
5. Sync only runs when the user is authenticated and a network connection is available
