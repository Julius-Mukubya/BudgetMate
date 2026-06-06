# BudgetMate
BudgetMate is a personal budgeting app built with Flutter that helps individuals track their income, plan expenditures, allocate funds to categories, and record actual spending. Built offline-first with Drift (SQLite) as the source of truth and Firebase for authentication and cloud sync.

__Stack:__ Flutter/Dart • Riverpod (state) • Drift/SQLite (local DB) • Firebase Auth + Firestore • go_router • freezed models

__Features:__

- Multi-user accounts with email/password authentication
- Custom budget periods with flexible date ranges
- Income recording (salary, bonuses, side income)
- Budget planning with expenditure categories
- Fund allocation (committed amounts ≤ total income)
- Spend transaction tracking
- Real-time dashboard with progress bars
- Variance analysis (planned vs actual, color-coded)
- Full offline functionality with seamless cloud sync
- Dark-only UI with Material 3 design system

