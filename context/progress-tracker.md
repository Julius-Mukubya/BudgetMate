# Progress Tracker

Update this file after every meaningful implementation change.

## Current Phase

Feature implementation complete through Step 9 (Transactions). Moving to UI screens.

## Completed

### Foundation (Steps 1-4)
- **Step 1**: Flutter project setup — `flutter create`, folder structure (30+ dirs), pubspec.yaml with all dependencies (Riverpod, Drift, Firebase, go_router, freezed, google_fonts, lucide_flutter)
- **Step 2**: Core theme — `app_theme.dart`, dark-only ColorScheme with all specified color tokens, Inter + JetBrains Mono fonts
- **Step 3**: Drift DB — 5 tables, 5 DAOs, `database.g.dart` generated, `database_provider.dart` with Riverpod providers
- **Step 4**: Firebase Auth — `auth_provider.dart` (firebaseAuthProvider, authStateProvider, currentUserIdProvider), LoginScreen, SignUpScreen
- **Navigation**: go_router with auth guard, AppShell with 5-tab bottom nav (Lucide icons)
- **Shared**: AmountDisplay widget, BudgetException class

### Feature Steps (5-9)
- **Step 5** (`6b7f046`): **Budget Periods** — PeriodListNotifier (create/list/delete), period_form bottom sheet (name + date pickers), periods_screen (list + FAB + empty state)
- **Step 6** (`26cd87f`): **Income** — IncomeListNotifier (family by periodId), income_form (source + amount + date), income_screen (total card + entries list), totalIncomeProvider
- **Step 7** (`5129349`): **Budget Plan** — CategoryListNotifier (family by periodId), category_form (name + planned amount), plan_screen (total planned + category list), totalPlannedProvider. Router updated with `/periods/:periodId/plan`
- **Step 8** (`d11cbfa`): **Allocation** — AllocationListNotifier, enforcement of **total allocations ≤ total income**, allocation_form (category dropdown + amount + remaining display), allocation_screen (total allocated/remaining + list), totalAllocatedProvider, remainingIncomeProvider
- **Step 9** (`4306b9f`): **Transactions** — TransactionListNotifier, enforcement of **transaction amount ≤ remaining category balance**, transaction_form (category + amount + date + optional note), transactions_screen (total spent + list), totalSpentProvider

### All Commits
```
86ef50a Initial project scaffold
6b7f046 Budget period feature
26cd87f Income feature
5129349 Budget Plan feature
d11cbfa Allocation feature
4306b9f Transaction feature
```

## In Progress

- **Step 10**: Dashboard screen — aggregated period view with progress bars
- **Step 11**: Variance screen — planned vs actual per category (color-coded, sortable)
- **Step 12**: History screen — past periods list with navigation to details
- **Step 13**: Firebase sync service — offline → online sync with last-write-wins

## Open Questions

- What currency does the primary user use? (Single-currency per user in v1)
- Budget period: confirm multiple income entries vs single salary entry?
- Category deletion: cascade delete allocations and transactions, or block?

## Architecture Decisions

- **Offline-first with Drift**: Local SQLite via Drift is the UI source of truth. Firestore is a sync target, not a read source.
- **Riverpod for state**: Chosen over Bloc for less boilerplate and better fit with Drift's stream-based query API.
- **Freezed for models**: All data models are immutable Freezed classes.
- **Allocation as separate from planning**: Plan = intent, Allocation = committed funds.
- **Auth guard at router level**: No manual auth checks in screens.
- **Business logic in providers**: Validation rules (date range, allocation ≤ income, transaction ≤ balance) enforced as typed BudgetException in the provider layer before DB writes.
- **Single feature per commit**: Each feature unit committed independently with passing `flutter analyze --no-pub`.

## Session Notes

- All 5 core data models have CRUD providers, forms, and screens
- `flutter analyze --no-pub` passes with no issues on current state
- Router currently uses `/periods` route pattern with periodId path params
- Proceeding with remaining UI screens (Dashboard, Variance, History) and sync service