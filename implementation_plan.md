# NetBakiye — Faz 1 (Core) MVP Implementation Plan

Build the foundational personal finance app with Flutter + Supabase. This phase covers: project setup, authentication, manual transaction entry, basic budgeting envelopes, manual asset tracking, and the 4-tab navigation shell with a premium dark-themed UI.

## User Review Required

> [!IMPORTANT]
> **Supabase project**: You will need an active Supabase project. The plan generates SQL migration files, but you must run them in your Supabase dashboard or CLI. If you already have a Supabase project, please share the URL and anon key (or I'll use placeholders).

> [!IMPORTANT]
> **Scope decision**: This plan covers **Faz 1 only** — manual data entry, basic budget envelopes, manual assets, and auth. Installment engine, KMH interest, Open Banking, and AI categorization are deferred to Faz 2–4 as described in the PRD. Confirm if you'd like a different scope.

---

## Proposed Changes

### 1 · Flutter Project Initialization

#### [NEW] Project root (`e:\onedrive\Belgeler\NetBakiye`)

- Run `flutter create` with org `com.netbakiye`, targeting iOS, Android, Web.
- Add dependencies to `pubspec.yaml`:
  - `supabase_flutter` — Supabase SDK
  - `flutter_riverpod` — state management
  - `go_router` — navigation
  - `intl` — date/currency formatting (₺)
  - `google_fonts` — Inter / Outfit typography
  - `fl_chart` — progress bars & charts
  - `uuid` — IDs
  - `flutter_svg` — icons

---

### 2 · Supabase Schema (SQL Migration)

#### [NEW] `supabase/migrations/001_initial_schema.sql`

Tables:

| Table | Key columns |
|---|---|
| `profiles` | `id (FK auth.users)`, `display_name`, `currency` |
| `accounts` | `id`, `user_id`, `name`, `type` (vadesiz/kredi_karti/kmh), `balance`, `credit_limit` |
| `categories` | `id`, `user_id`, `name`, `icon`, `color`, `is_income` |
| `transactions` | `id`, `user_id`, `account_id`, `category_id`, `amount`, `note`, `date`, `is_installment` |
| `budgets` | `id`, `user_id`, `category_id`, `month`, `allocated`, `spent` |
| `assets` | `id`, `user_id`, `type` (ceyrek_altin/gram_altin/usd/eur), `quantity`, `purchase_price_try` |
| `goals` | `id`, `user_id`, `name`, `target_amount`, `saved_amount`, `deadline`, `icon` |

Row Level Security (RLS) policies: each table filtered by `auth.uid() = user_id`.

---

### 3 · Dart Data Models & Service Layer

#### [NEW] `lib/models/` — Immutable model classes

- `account.dart`, `transaction_model.dart`, `category.dart`, `budget.dart`, `asset.dart`, `goal.dart`, `profile.dart`

#### [NEW] `lib/services/supabase_service.dart`

- Initialize Supabase client
- CRUD methods per table
- Real-time subscription helpers

#### [NEW] `lib/providers/` — Riverpod providers

- `auth_provider.dart`, `accounts_provider.dart`, `transactions_provider.dart`, `budgets_provider.dart`, `assets_provider.dart`, `goals_provider.dart`

---

### 4 · Authentication

#### [NEW] `lib/screens/auth/login_screen.dart`
#### [NEW] `lib/screens/auth/register_screen.dart`

- Email + password sign-up / login
- Post-auth redirect to Dashboard
- Session persistence via `supabase_flutter`

---

### 5 · App Shell & Navigation

#### [NEW] `lib/app.dart`

- `MaterialApp.router` with `GoRouter`
- Bottom navigation bar with 4 tabs: Dashboard, Budget, Accounts, Goals
- Premium dark theme with gradient AppBar

---

### 6 · Dashboard (Ana Ekran)

#### [NEW] `lib/screens/dashboard/dashboard_screen.dart`

- **Gerçek Net Bakiye** hero card: sum of account balances + asset values − debts
- **Safe to Spend** large number: balance − upcoming budgeted obligations for the remainder of the month
- **Proactive alerts** list (placeholder cards for Faz 2 items like KMH warnings)
- **FAB**: opens a bottom sheet for quick transaction entry (3-tap: amount → category → save)

#### [NEW] `lib/screens/dashboard/widgets/` — reusable dashboard widgets

- `balance_hero.dart`, `safe_to_spend_card.dart`, `alert_card.dart`, `quick_add_sheet.dart`

---

### 7 · Budget & Calendar (Planlama)

#### [NEW] `lib/screens/budget/budget_screen.dart`

- **Unassigned money** banner: income total − sum of all budget allocations
- **Category envelopes** list: each shows name, allocated, spent, remaining with animated progress bar
- Add/edit budget allocation dialog
- Placeholder calendar strip (Faz 4 will make it interactive)

#### [NEW] `lib/screens/budget/widgets/`

- `unassigned_banner.dart`, `envelope_card.dart`, `budget_dialog.dart`

---

### 8 · Accounts & Assets

#### [NEW] `lib/screens/accounts/accounts_screen.dart`

- **Accounts section**: list of bank accounts with balance, colored by type
- **Assets section**: list of manually entered assets with quantity & estimated TL value
- Add/edit account and asset dialogs

#### [NEW] `lib/screens/accounts/widgets/`

- `account_tile.dart`, `asset_tile.dart`, `add_account_dialog.dart`, `add_asset_dialog.dart`

---

### 9 · Goals & Reports

#### [NEW] `lib/screens/goals/goals_screen.dart`

- Gamified goal cards with animated progress ring
- Add/edit goal dialog
- Placeholder "Röntgen Raporu" textual report section

#### [NEW] `lib/screens/goals/widgets/`

- `goal_card.dart`, `add_goal_dialog.dart`, `report_section.dart`

---

### 10 · Theming & Design System

#### [NEW] `lib/theme/app_theme.dart`

- Dark mode first, with sleek gradient accent (teal → cyan)
- Google Fonts (Inter for body, Outfit for headings)
- Consistent border radius, elevation, card styling
- Custom color scheme: deep dark background (#0D1117), card surface (#161B22), accent gradient

#### [NEW] `lib/theme/app_colors.dart`
#### [NEW] `lib/utils/formatters.dart` — currency (₺) & date formatters

---

## Verification Plan

### Automated Tests

Since this is a new project with no existing tests to leverage, verification will focus on build and runtime validation:

1. **Build check** — `flutter build web --release` must succeed with zero errors.
2. **Analyze** — `flutter analyze` must report no errors (warnings acceptable for initial scaffold).
3. **Unit test (models)** — A basic `test/models_test.dart` verifying model serialization round-trips (fromJson → toJson) for all 7 models.

### Manual / Browser Verification

1. Run `flutter run -d chrome` and visually confirm:
   - Auth screens render and the login/register forms appear
   - Bottom nav shows 4 tabs and tapping switches screens
   - Dashboard shows the balance hero, Safe to Spend card, and FAB
   - FAB opens quick-add bottom sheet
   - Budget screen shows the unassigned banner and envelope list (empty state)
   - Accounts screen shows empty-state add buttons
   - Goals screen shows empty-state goal list
2. Verify dark theme renders correctly with gradient accents across all screens.

> [!NOTE]
> Full end-to-end Supabase tests require a live project. Initial build verification will use mock data or offline mode until Supabase credentials are configured.
