# Budgetly – Personal Budget Planner

Budgetly is a Vietnamese, local-first personal finance app for planning monthly spending and tracking savings. It is an independent design and does not require an account or backend.

## Features

- Monthly budgets with editable category limits and remaining balance.
- Expense creation and deletion, with monthly/category totals and 80%/100% usage indicators.
- Savings goals with due dates, progress capped at 100%, deposits and withdrawals.
- Reports for category spending, budget use and six-month budget/spending comparison.
- Responsive Material 3 layout with light and dark themes.
- Persistent on-device storage using Hive.

## Technology stack

Flutter and Dart, Material 3, Riverpod, Hive and hive_flutter, fl_chart, intl, uuid.

## Architecture

`lib/core` contains data models, Hive storage, providers and shared widgets. Feature screens are separated into `dashboard`, `budgets`, `savings`, `reports` and `settings`. Feature actions go through `BudgetActions`; the dashboard and reports derive totals from persisted expenses and budgets.

## Installation

Install Flutter (Dart SDK constraint: `^3.10.4`), then from the repository root run:

```sh
flutter pub get
```

## Run

```sh
flutter run -d <device-id>
```

Android and Windows runners are included. Windows desktop builds require the Windows desktop workload and Visual Studio C++ build tools.

## Screenshots

Screenshots can be added here after running the app on Android or Windows.

## Future improvements

- Expense editing and recurring transactions.
- CSV export and richer period filters.
- Optional local backup/restore and currency preferences.
- Automated unit and widget coverage for budget and savings workflows.
