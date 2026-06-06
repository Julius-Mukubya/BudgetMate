# UI Context

## Theme

Dark only. No light mode in v1. The design language is a clean financial
workspace — deep dark backgrounds, elevated card surfaces, and a green
accent for positive financial states (income, remaining balance). Red
is reserved for overspent or error states.

## Colors

All widgets must use these theme color roles — no hardcoded hex values.
Define these as a ThemeData ColorScheme in `lib/core/theme/app_theme.dart`.

| Role                | Token Name             | Value     |
| ------------------- | ---------------------- | --------- |
| Page background     | `colorScheme.surface`  | `#0F1117` |
| Card / elevated     | `colorScheme.surfaceContainerHigh` | `#1C1F2A` |
| Primary text        | `colorScheme.onSurface` | `#F0F2F5` |
| Muted / secondary   | `colorScheme.onSurfaceVariant` | `#8A8FA8` |
| Primary accent      | `colorScheme.primary`  | `#4ADE80` |
| On primary          | `colorScheme.onPrimary` | `#022C16` |
| Error               | `colorScheme.error`    | `#F87171` |
| Border / divider    | `colorScheme.outlineVariant` | `#2A2D3A` |
| Success / positive  | `colorScheme.tertiary` | `#4ADE80` |
| Warning             | `colorScheme.secondary` | `#FBBF24` |

## Typography

Use Google Fonts — `Inter` for UI text, `JetBrains Mono` for currency amounts.

| Role              | Style                        |
| ----------------- | ---------------------------- |
| Page title        | `titleLarge` — Inter 20 600  |
| Section heading   | `titleMedium` — Inter 16 600 |
| Body text         | `bodyMedium` — Inter 14 400  |
| Muted label       | `labelSmall` — Inter 12 400  |
| Currency amount   | `JetBrains Mono` 16–24 600   |

## Spacing and Radius

- Base spacing unit: 8px. Use multiples: 4, 8, 12, 16, 24, 32.
- Card border radius: 12px
- Button border radius: 10px
- Input field border radius: 8px
- Modal / bottom sheet border radius (top): 16px

## Component Library

Use Flutter Material 3 widgets as the base. Extend with custom components
in `lib/core/widgets/`. Do not reinvent standard widgets — wrap them with
consistent theme application.

Key custom components to build:
- `AmountDisplay` — JetBrains Mono currency display with color coding
- `BudgetProgressBar` — allocated vs spent bar with label
- `PeriodCard` — summary card for a budget period in the history list
- `CategoryTile` — list tile showing a category with its balance state
- `BottomSheetForm` — standard bottom sheet wrapper for add/edit forms

## Layout Patterns

- **Dashboard**: Scrollable single-column with a summary header card, then
  per-category tiles below
- **Forms**: Modal bottom sheets (not full pages) for add/edit actions
- **Lists**: Sliver-based scrolling for period history and transaction lists
- **Navigation**: Bottom navigation bar with 5 tabs:
  Dashboard | Budget Plan | Transactions | Variance | History
- **FAB**: Floating action button on Dashboard and Transactions screens
  for quick-add spend

## Icons

Use `lucide_flutter` package. Stroke icons only.
Sizes: 18 for inline, 22 for navigation, 24 for FAB and action buttons.
