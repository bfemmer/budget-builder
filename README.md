# Budget Builder

[![Flutter](https://img.shields.io/badge/Flutter-^3.13.2-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-^3.0.0-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Accessibility](https://img.shields.io/badge/WCAG%202.1-AAA%20Compliant-008000?style=for-the-badge)](https://www.w3.org/WAI/standards-guidelines/wcag/)
[![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](LICENSE)


**Budget Builder** is a modern, responsive, offline-first personal finance and expense tracking mobile application specifically tailored for **U.S. Air Force Airmen**, **Space Force Guardians**, and military family members. Designed around military pay structures and Air & Space Forces Aid Society (AFAS) guidelines, Budget Builder empowers service members to take control of their finances, track essential vs. discretionary spending, and quickly access emergency financial assistance when needed.

---

## 🌟 Key Features

### 📊 1. Monthly Budget Dashboard
- **Monthly Overview Hero Card**: Real-time spending progress indicator showing total spent against configured monthly limits, remaining budget balance, and spending health status (*ON TRACK* vs. *OVER BUDGET*).
- **Need vs. Want Breakdown**: Instant visual comparison separating essential living expenses (*Needs*) from discretionary spending (*Wants*).
- **Rank Insignia Header**: Displays rank-tailored U.S. Air Force insignia graphics alongside personalized greeting messages.
- **Quick Action Bar**: One-tap shortcuts to record expenses, set spending limits, view analytics reports, or navigate directly to emergency financial relief resources.
- **Budget Threshold Alerts**: Notification sheet alerting users when category spending reaches critical warning thresholds.

### 💳 2. Transaction Ledger & Expense Tracking
- **Detailed Expense & Income Logging**: Track item description, dollar amount, category, date, merchant/vendor name, payment type (*Cash/Debit* vs. *Credit Card*), and *Need vs. Want* classification tag.
- **Filtering & Search**: Quickly search transactions by vendor or description, or filter by *Needs Only* or *Wants Only*.
- **Full CRUD Capabilities**: Edit existing entries or remove transactions with confirmation prompts.
- **Android Safe Area Integration**: Custom bottom sheet modals engineered with `useSafeArea: true` to prevent overlap with Android system navigation bars.

### 📈 3. Spending Track & Category Analytics
- **Threshold Health Indicator**:
  - 🟢 **Green**: Category spending is below 50% of monthly limit.
  - 🟡 **Yellow**: Category spending has reached 50% – 79% of limit.
  - 🔴 **Red**: Category spending has reached or exceeded 80% of limit.
- **Category Detail Views**: In-depth transaction histories, remaining balance calculations, and percentage progress per category.

### 📊 4. Financial Reports, Month Selection & PDF Export
- **Flexible Timeframe Filtering**: Filter financial metrics across *Last 7 Days*, *Last Month*, *Year-to-Date (YTD)*, or select any **Specific Month** using the interactive Month & Year picker dialog.
- **Executive Cash Flow Summary**: Real-time calculation of total income, total expenses, net cash flow balance (*Net Surplus* vs. *Net Deficit*), and record counts.
- **Financial Awareness Breakdown**: Essential (*Needs*) vs. discretionary (*Wants*) expense analysis with percentage breakdown metrics.
- **Category & Income Breakdown**: Itemized category spending progress bars and income source listings.
- **Executive PDF Report Export**: 1-click PDF document generation producing professional financial reports complete with executive headers, cash flow cards, category breakdown tables, and detailed transaction logs. Supports saving, printing, or sharing via native OS share sheets.

### 🛡️ 5. AFAS Emergency Financial Assistance & Guidance
- **Educational Portal**: Detailed guides on assistance offered by the **Air and Space Forces Aid Society** (Standard Assistance, Emergency Relief, Education Grants, Falcon Loans).
- **4-Step Application Guide**: Clear walkthrough explaining how Airmen and Guardians can apply for AFAS financial support.
- **Emergency Eligibility Checklist**: Interactive checklist helping users verify if their unexpected expense qualifies under emergency criteria.
- **24/7 Red Cross Emergency Contact**: Direct 1-click dialer (`1-877-272-7337`) for after-hours emergency assistance and offline landline reference.
- **Direct Portal Launcher**: 1-click button to open the official AFAS portal (`portal.afas.org`).
- **FAQ Accordion**: Expandable answers addressing common questions regarding loans, grants, and eligibility.

### 🎖️ 6. Military Rank Integration & Profile Management
- **Official USAF Rank Insignia Assets**: Transparent PNG graphics representing:
  - **Enlisted Ranks (E-2 to E-9)**: Airman (E-2), Airman First Class (E-3), Senior Airman (E-4), Staff Sergeant (E-5), Technical Sergeant (E-6), Master Sergeant (E-7), Senior Master Sergeant (E-8), Chief Master Sergeant (E-9).
  - **Officer Ranks (O-1 to O-6)**: 2nd Lieutenant (O-1), 1st Lieutenant (O-2), Captain (O-3), Major (O-4), Lieutenant Colonel (O-5), Colonel (O-6).
  - **General Officers**: Single-Star General Officer badge.
- **Profile Customization**: Store personal details including First/Last Name, Rank/Paygrade, Duty Station/Base, Gender, Date of Birth, Household Family Size, and Email.
- **Live Badge Preview**: Changing rank in settings updates profile cards and top dashboard headers across the app in real-time.

### 🎨 7. Theme Engine & WCAG AAA Contrast Accessibility
- **Light, Dark & System Theme Modes**: Seamless mode toggling persisted using `SharedPreferences` initialized prior to application startup to eliminate frame-1 mode flickering.
- **WCAG AA/AAA Compliant Palette**: Tailored text and background colors (`#14532D`, `#581C87`, `#1E40AF`, `#9D174D`) delivering 8:1 to 9.1:1 contrast ratios on choice chips, filter chips, tag badges, and bottom modal sheets in both Light and Dark modes.
- **Material Ink Splash Safety**: Custom `Material` container wrappers preventing framework rendering assertions and ensuring smooth touch ripple feedback.

### 💾 8. Data Transfer & Offline Persistence
- **Offline Storage**: Powered by SQLite (`sqflite`) for reliable offline operation without requiring constant internet connection.
- **Backup & Restore**: Export and restore budget data seamlessly from device storage.

---

## 🏗️ Architecture & Technology Stack

Budget Builder follows **Clean Architecture** principles structured by feature:

```
lib/
├── core/
│   ├── sqlite/               # Database tables, seeding, and SQLite helper
│   ├── theme/                # WCAG-compliant color palette, app theme, & theme viewmodel
│   └── utils/                # Currency, date, rank helper, & URL launcher utilities
└── features/
    ├── assistance/           # AFAS Assistance educational screen & eligibility checklist
    ├── categories/           # Spending limits & category CRUD viewmodel/screens
    ├── dashboard/            # Overview hero card, quick actions, & notification sheet
    ├── data_transfer/        # Backup & restore data management
    ├── profile/              # User profile entity, model, repository, & screen
    ├── reports/              # Visual expense breakdown, month selector, & PDF report generator
    ├── track/                # Category threshold tracking & category detail screen
    └── transactions/         # Transaction ledger, add/edit modal, & filter chips
```

### Dependencies
- **State Management**: `provider` (^6.1.5)
- **Local Database**: `sqflite` (^2.4.4)
- **Persistence**: `shared_preferences` (^2.5.6)
- **PDF Generation & Export**: `pdf` (^3.13.1) & `printing` (^5.15.1)
- **Path Utilities**: `path` & `path_provider`
- **Formatting**: `intl` (^0.20.3)
- **URL Launcher**: `url_launcher` (^6.3.3)

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.13.2` or later)
- Dart SDK (`^3.1.0` or later)
- Xcode (for iOS simulator) or Android Studio (for Android emulator)

### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/bfemmer/budget-builder.git
   cd budget-builder
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Static Analysis**:
   ```bash
   flutter analyze
   ```

4. **Execute Unit & Widget Tests**:
   ```bash
   flutter test
   ```

5. **Launch the Application**:
   ```bash
   flutter run
   ```

---

## 🧪 Quality Assurance & Verification

Budget Builder adheres to strict software quality guidelines:
- **Zero Static Analysis Warnings**: Verified with `flutter analyze`.
- **Automated Test Suite**: Verified with `flutter test`.
- **WCAG AAA Contrast**: Tested across Light and Dark themes.
- **Android System Insets**: Verified safe area behavior for all bottom modal sheets.

---

## 📄 License & Acknowledgments

- Designed & Developed for U.S. Air Force Airmen and Guardians.
- Air & Space Forces Aid Society (AFAS) information provided courtesy of [afas.org](https://afas.org).
- Military rank insignia graphics are public domain U.S. Government works.
