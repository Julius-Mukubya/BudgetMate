# Progress Tracker

Update this file after every meaningful implementation change.

## Current Phase

All 13 build steps complete. Currency model added, category deletion blocked. Ready for Firebase project configuration and testing.

## Completed

### Foundation (Steps 1-4)
- **Step 1**: Flutter project setup — `flutter create`, folder structure (30+ dirs), pubspec.yaml with all dependencies (Riverpod, Drift, Firebase, go_router, freezed, google_fonts, lucide_flutter)
- **Step 2**: Core theme — `app_theme.dart`, dark-only ColorScheme with all specified color tokens, Inter + JetBrains Mono fonts
- **Step 3**: Drift DB — 5 tables, 5 DAOs, `database.g.dart` generated, `database_provider.dart` with Riverpod providers
- **Step 4**: Firebase Auth — `auth_provider.dart` (firebaseAuthProvider, authStateProvider, currentUserIdProvider), LoginScreen, SignUpScreen
- **Navigation**: go_router with auth guard, AppShell with 5-tab bottom nav (Lucide icons)
- **Shared**: AmountDisplay widget, BudgetException class, BudgetProgressBar widget

### Feature Steps (5-13)
- **Step 5** (`6b7f046`): **Budget Periods** — PeriodListNotifier (create/list/delete), period_form bottom sheet (name + date pickers), periods_screen (list + FAB + empty state)
- **Step 6** (`26cd87f`): **Income** — IncomeListNotifier (family by periodId), income_form (source + amount + date), income_screen (total card + entries list), totalIncomeProvider
- **Step 7** (`5129349`): **Budget Plan** — CategoryListNotifier (family by periodId), category_form (name + planned amount), plan_screen (total planned + category list), totalPlannedProvider
- **Step 8** (`d11cbfa`): **Allocation** — AllocationListNotifier, enforcement of **total allocations ≤ total income**, allocation_form (category dropdown + amount + remaining display), allocation_screen (total allocated/remaining + list), totalAllocatedProvider, remainingIncomeProvider
- **Step 9** (`4306b9f`): **Transactions** — TransactionListNotifier, enforcement of **transaction amount ≤ remaining category balance**, transaction_form (category + amount + date + optional note), transactions_screen (total spent + list), totalSpentProvider
- **Step 10** (`d0c365c`): **Dashboard** — dashboardDataProvider + categoryBreakdownsProvider (aggregated period data), BudgetProgressBar widget, dashboard_screen (4 summary cards + per-category progress bars)
- **Step 11** (`e881da2`): **Variance** — VarianceItem model (variance + variancePercent), VarianceSort enum (mostOverspent/mostUnderspent/categoryName), varianceListProvider + sortedVarianceProvider, variance_screen (period-level summary + color-coded list: green/amber/red, sortable via PopupMenu)
- **Step 12** (`c095b3a`): **History** — history_screen (past periods list from periodListProvider, tap to navigate)
- **Step 13** (`a125389`): **Firebase Sync Service** — SyncService class at `lib/core/sync/sync_service.dart`, pushes unsynced records (syncedAt = null) for all 5 tables to Firestore collections namespaced by userId, uses FieldValue.serverTimestamp() for updatedAt, marks records synced after push

### Post-Scope Enhancements
- **Currency model** (`cf50ed7`): 10 supported currencies (UGX, KES, TZS, RWF, USD, EUR, GBP, NGN, ZAR, GHS) with dynamic symbol in all 4 forms (income, category, allocation, transaction). `Currency.supported` list, `selectedCurrencyProvider` (StateProvider, defaults to UGX), `currencySymbolProvider` (derived string)
- **Category deletion guard** (`cf50ed7`): `CategoryListNotifier.delete()` now checks for existing transactions via `transactionDao.totalByCategory(id)` before deleting. Throws `BudgetException` with type `categoryNotEmpty` if transactions exist.

### All Commits (on main)
```
cf50ed7 Currency model with 10 supported currencies, dynamic symbol, block category deletion if transactions exist
734abb0 Update progress-tracker: all 13 steps complete, open questions resolved/statused
a125389 Firebase sync service: push unsynced local records to Firestore
c095b3a History screen: past periods list with navigation to detail
e881da2 Variance screen: planned vs actual per category with color-coding and sort options
d0c365c Dashboard screen: aggregated view with summary cards and per-category progress bars
67dc8f4 Update progress-tracker with complete state across all 9 completed steps
4306b9f Transaction feature: record spend transactions enforcing remaining balance invariant
d11cbfa Allocation feature: allocate income to categories with total income invariant
5129349 Budget Plan feature: categories with planned amounts, add/delete, total display
26cd87f Income feature: record/list income entries with total display
6b7f046 Budget period feature: create/list/delete periods with bottom sheet form
86ef50a Initial project scaffold: Flutter setup, dark theme, Drift DB, Firebase Auth, go_router, 5-tab AppShell, shared widgets
```

## Remaining Work (Firebase Activation)

For Auth and Firestore to work, you need to complete these manual setup steps:

1. **Firebase Console Setup** — Create project, register Android + iOS apps
2. **Download google-services.json** → `android/app/google-services.json`
3. **Download GoogleService-Info.plist** → `ios/Runner/`
4. **Enable Email/Password authentication** in Firebase Console
5. **Create Firestore Database** in test mode
6. **Add Android Gradle plugin** — `id("com.google.gms.google-services")` in `android/app/build.gradle.kts`
7. **Wire SyncService** into the app lifecycle (call `pushUnsynced()` on app start / after writes)

## Open Questions — All Resolved

| Question | Status | Resolution |
|----------|--------|-----------|
| What currency does the primary user use? | **Resolved** | 10-currency model with dynamic symbol. `Currency.supported` list allows user selection at runtime via `selectedCurrencyProvider`. Default is UGX. |
| Budget period: confirm multiple income entries vs single salary entry? | **Resolved** | Built as multiple income entries per period (matches architecture.md spec). IncomeEntriesTable and income_form support multiple entries. |
| Category deletion: cascade delete or block? | **Resolved** | **Block if transactions exist.** `CategoryListNotifier.delete()` throws `BudgetException` (`categoryNotEmpty`) when transactions > 0. Prevents accidental data loss. |

## Architecture Decisions

- **Offline-first with Drift**: Local SQLite via Drift is the UI source of truth. Firestore is a sync target, not a read source.
- **Riverpod for state**: Chosen over Bloc for less boilerplate and better fit with Drift's stream-based query API.
- **Freezed for models**: All data models are immutable Freezed classes (code-generated by drift_dev).
- **Allocation as separate from planning**: Plan = intent, Allocation = committed funds.
- **Auth guard at router level**: No manual auth checks in screens — go_router redirect handles it.
- **Business logic in providers**: Validation rules (date range, allocation ≤ income, transaction ≤ balance, category not empty) enforced as typed BudgetException in the provider layer before DB writes.
- **Single feature per commit**: Each feature unit committed independently with passing `flutter analyze --no-pub`.
- **Sync via DAO pattern**: SyncService uses the same DAO update patterns as feature code — no direct table access from sync layer.
- **Dynamic currency via Riverpod**: Currency symbol is provided via `currencySymbolProvider` and consumed by all forms as `ConsumerStatefulWidget` — switching currency at runtime updates all form prefixes automatically.

## Session Notes

- Total Dart source files: **40** (38 features + 2 new: currency.dart, currency_provider.dart)
- All files compile with zero analyzer issues
- Both open questions from the initial context files are now resolved and implemented
- The only remaining manual step is Firebase project setup (google-services.json + Gradle plugin)