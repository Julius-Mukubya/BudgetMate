# BudgetMate 💰

A personal budgeting app built with **Flutter** and **Firebase** — designed for offline-first budget management with cloud sync capabilities.

---

## ✨ Features

- **📊 Dashboard** — Get an at-a-glance overview of your finances with spending summaries and progress indicators.
- **📝 Budget Planning** — Define custom budget categories and set allocation targets for each period.
- **💰 Income Tracking** — Log and manage multiple income entries across different periods.
- **📦 Allocation Management** — Allocate funds from your income to specific budget categories.
- **💸 Transaction Recording** — Track expenses and deposits against your budget allocations.
- **📈 Variance Analysis** — Compare planned vs. actual spending to identify where you're over/under budget.
- **📜 History** — Browse past budget periods and review financial records.
- **🔐 Authentication** — Sign in securely with email/password or Google Sign-In via Firebase Auth.
- **☁️ Cloud Sync** — Data is stored locally with Drift (SQLite) and synced to Firebase Firestore.
- **👤 Multi-Currency Support** — Manage budgets in your preferred currency.
- **📱 Cross-Platform** — Runs on Android and iOS.

---

## 🛠️ Tech Stack

| Layer          | Technology                              |
|----------------|-----------------------------------------|
| **Framework**  | Flutter + Dart                          |
| **State Mgmt** | Riverpod (with code generation)         |
| **Local DB**   | Drift (SQLite)                          |
| **Auth**       | Firebase Authentication                 |
| **Cloud DB**   | Cloud Firestore                         |
| **Routing**    | GoRouter                                |
| **UI**         | Google Fonts, Lucide Icons              |
| **Models**     | Freezed + JSON Serialization            |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.9.0
- Firebase project (see setup below)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/budgetmate.git
cd budgetmate

# Install dependencies
flutter pub get

# Generate code (freezed, riverpod, drift)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Firebase Setup

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com).
2. Register your Android and iOS apps in the project.
3. Download the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. Enable **Email/Password** and **Google Sign-In** under Firebase Authentication.
5. Add your **SHA-1 certificate fingerprint** to the Android app settings (Firebase Console).
6. Run the FlutterFire CLI to regenerate `lib/firebase_options.dart`:

```bash
flutterfire configure
```

> **Note:** The `firebase_options.dart` file is already configured for this project. If you recreate it, update the values accordingly.

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase configuration
├── core/
│   ├── theme/app_theme.dart           # App-wide theme
│   ├── router/app_router.dart         # Route definitions
│   ├── db/                            # Database layer
│   │   ├── database.dart              # Drift database definition
│   │   ├── database_provider.dart     # Riverpod provider for DB
│   │   ├── tables/                    # Table definitions
│   │   └── daos/                      # Data access objects
│   ├── models/                        # Shared models
│   ├── widgets/                       # Shared widgets
│   ├── sync/sync_service.dart         # Cloud sync logic
│   └── exceptions/                    # Custom exceptions
├── features/
│   ├── auth/                          # Authentication (login, signup)
│   ├── dashboard/                     # Dashboard screen
│   ├── periods/                       # Budget periods
│   ├── income/                        # Income entries
│   ├── plan/                          # Budget planning & categories
│   ├── allocation/                    # Fund allocation
│   ├── transactions/                  # Expenses & deposits
│   ├── variance/                      # Variance analysis
│   └── history/                       # Historical records
```

---

## 📄 License

MIT