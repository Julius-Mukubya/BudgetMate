```markdown
# BudgetMate — Flutter Budget App

## Overview

BudgetMate is a mobile budgeting app built with Flutter that helps individuals
track their income, plan expenditures, allocate funds to categories, and record
actual spending. It supports multiple user accounts, works offline with local
storage, and syncs to a cloud backend when online.

## Goals

1. Allow users to record salary or any income source for a flexible budget period
2. Let users plan and allocate their budget across expenditure categories before spending
3. Track actual spending against allocations in real time, with clear remaining balances
4. Support multiple users with isolated data and account-based access
5. Work fully offline and sync seamlessly when an internet connection is available

## Core User Flow

1. User signs up or logs in
2. User creates a new budget period (e.g. "June 2025", or a custom date range)
3. User records their income (salary or other sources) for that period
4. User creates a budget plan — a list of expenditure categories with planned amounts
5. User allocates amounts from their income to each category (total allocation ≤ income)
6. When spending occurs, user records a transaction against a category
7. App shows remaining balance per category and overall unspent balance
8. User can review history of past budget periods

## Features

### Income Management
- Record one or more income entries per budget period (salary, bonus, side income)
- Label each income source
- View total income for the period

### Budget Planning
- Create expenditure categories (e.g. Rent, Food, Transport, Savings)
- Set a planned amount per category
- System warns if total planned exceeds total income

### Allocation
- Allocate actual funds from income to each category
- Allocation can differ from the plan (plan is a guide, allocation is committed)
- Total allocation cannot exceed total income

### Spending / Transactions
- Record a spend transaction: amount, category, date, optional note
- Transactions reduce the remaining balance of the category
- View transaction history per category and per period

### Dashboard
- Overview of the current budget period: total income, total allocated, total spent, remaining
- Per-category progress bar: allocated vs spent
- Quick-add spend button

### Variance Analysis
- Compare planned amount vs actual spending per category for any budget period
- Show variance as both an absolute value (e.g. -UGX 15,000) and a percentage (e.g. -12%)
- Color-code: green if under budget, red if over budget, amber if within 10% of limit
- Period-level summary: total planned vs total spent, overall variance
- Available for both active (in-progress) and completed periods
- Sortable by most overspent, most underspent, or by category name

### History
- List of all past budget periods
- Tap into any period to review its income, plan, allocations, transactions, and variance

### Multi-User Accounts
- Each user has their own account (email + password)
- Data is fully isolated per user
- No shared budgets in v1 (out of scope)

## Scope

### In Scope
- Flutter mobile app (Android + iOS)
- Flexible budget periods with custom date ranges
- Income recording, budget planning, allocation, and spend tracking
- Multi-user accounts with authentication
- Offline-first local storage with cloud sync when online

### Out of Scope
- Shared or collaborative budgets
- Bank integrations or automatic transaction import
- Currency conversion (single currency per user)
- Web version
- Notifications or reminders (v1)

## Success Criteria

1. A signed-in user can create a budget period, record income, and plan a budget
2. Allocations correctly prevent over-allocation beyond total income
3. Spending transactions correctly reduce category balances
4. The dashboard reflects accurate real-time figures
5. Data persists offline and syncs correctly when the user comes back online
6. Variance analysis correctly shows planned vs actual per category with correct color coding
7. Two separate user accounts have fully isolated data

```
