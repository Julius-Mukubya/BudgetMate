# Progress Tracker

Update this file after every meaningful implementation change.

## Current Phase

Building features: Period management and Income recording.

## Completed

- Step 1: Flutter project setup with `flutter create`, organized folder structure (all 30+ directories), and pubspec.yaml with all dependencies (Riverpod, Drift, Firebase, go_router, freezed, google_fonts, lucide_flutter)
- Step 2: Core theme (`app_theme.dart`) — dark-only ColorScheme with all specified color tokens, Inter text theme, spacing/radius tokens via ThemeData
- Step 3: Drift database schema — 5 tables (BudgetPeriodsTable, IncomeEntriesTable, CategoriesTable, AllocationsTable, TransactionsTable) + 5 DAOs (BudgetPeriodDao, IncomeEntryDao, CategoryDao, AllocationDao, TransactionDao) + database.g.dart generated
- Step 4: Firebase Auth integration — auth_provider.dart (firebaseAuthProvider, authStateProvider, currentUserIdProvider) + LoginScreen + SignUpScreen
- Step 5: Placeholder screens for all 5 tabs (Dashboard, Plan, Transactions, Variance, History)
- Step 6: Router with auth guard (redirects unauthenticated users to /login)
- Step 7: AppShell with bottom navigation bar (5 tabs using Lucide icons)
- Step 8: Shared widgets (AmountDisplay using JetBrains Mono)
- Step 9: Core Exception class (BudgetException with typed enum)
- Step 10: Budget Period feature — `period_provider.dart` (PeriodListNotifier with create/delete), `period_form.dart` (bottom sheet with name, start/end date pickers), `periods_screen.dart` (list view with FAB to create, swipe/delete)

## In Progress

- Step 11: Income feature — provider, form, and screen
- Step 12: Budget Plan feature (categories + planned amounts)
- Step 13: Allocation feature (allocate income to categories, enforce ≤ total income)
- Step 14: Transaction feature (record spend, enforce ≤ remaining balance)
- Step 15: Dashboard screen (aggregated period view with progress bars)
- Step 16: Variance screen (planned vs actual per category, color-coded, sortable)
- Step 17: History screen (past periods list)
- Step 18: Firebase sync service (offline → online sync with last-write-wins)

## Open Questions

- What currency does the primary user use? (Single-currency per user in v1)
- Budget period: confirm multiple income entries vs single salary entry?
- Category deletion: cascade delete allocations and transactions, or block?

## Architecture Decisions

- **Offline-first with Drift**: Local SQLite via Drift is the UI source of truth.
  Firestore is a sync target, not a read source.
- **Riverpod for state**: Chosen over Bloc for less boilerplate and better fit
  with Drift's stream-based query API.
- **Freezed for models**: All data models are immutable Freezed classes.
- **Allocation as separate from planning**: Plan = intent, Allocation = committed funds.
- **Auth guard at router level**: No manual auth checks in screens.
- **Widgets are ConsumerWidget**: All screens extend ConsumerWidget or ConsumerStatefulWidget.