# Vestie — Flutter Fintech App

A collaborative savings app built in Flutter where users can create and join savings projects (vacations, emergencies, investments). Full Figma-accurate UI with Clean Architecture + BLoC/Cubit.

---

## Quick Start

```bash
flutter pub get
flutter run
```

> Requires Flutter 3.x · Dart 3.x · Android SDK 21+ · iOS 14+

---

## Tech Stack

| Concern | Package |
|---------|---------|
| State management | `flutter_bloc`, `equatable` |
| Navigation | `go_router` |
| UI scaling | `flutter_screenutil` (390 × 844 design base) |
| Typography | `google_fonts` — Inter throughout |
| SVG rendering | `flutter_svg` |
| Image picker | `image_picker` |
| URL launch | `url_launcher` |
| Secure storage | `flutter_secure_storage` |
| Local prefs | `shared_preferences` |
| HTTP | `dio` (stubbed — ready for real API) |

---

## Docs

- **Architecture & flow map** (roles, routes, join paths, project types, navigation patterns): [`DOCS/architecture_flows.md`](DOCS/architecture_flows.md)
- **Group Vacation & Emergency member flows** (screens, routes, UI-only vs API, integration checklist): [`DOCS/group_vacation_emergency_member_flow.md`](DOCS/group_vacation_emergency_member_flow.md)

---

## Architecture

```
lib/
├── app/
│   ├── main_app.dart            # ScreenUtilInit + MultiBlocProvider + MaterialApp.router
│   └── router/
│       ├── app_router.dart      # GoRouter
│       └── app_routes.dart      # Route path constants (never raw strings)
│
├── core/
│   ├── constants/               # AppStrings, AppAssets, AppDimens, ApiConstants, …
│   ├── theme/                   # AppColors, AppTheme
│   ├── utils/                   # validation_utils, app_snackbar, …
│   ├── widgets/common/          # AppButton, AppTextField, AppText, AppLoader, …
│   └── di/                      # service_locator (when used)
│
├── features/                    # Shared / cross-role modules
│   ├── auth/
│   ├── profile/
│   ├── projects/
│   ├── project_detail/
│   ├── wallet/
│   └── …
│
├── leader/                      # Project owner (leader) flows
│   └── features/
│       ├── create_project/      # Wizard: amount → details → settings → review → success
│       └── project_detail/
│
└── user/                        # Member / contributor flows
    └── features/
        ├── home/
        ├── discover/
        ├── contributions/
        ├── create_project_member_fund/
        └── …
```

**Create-project wizard state:** `CreateProjectCubit` is provided at **`MainApp`** so it survives all pushed wizard routes under `leader/features/create_project/`.

---

## Screen Map

### Auth Flow

| Screen | Route | State |
|--------|-------|-------|
| Splash | `/` | — |
| Onboarding (3 pages) | `/onboarding` | `OnboardingCubit` |
| Login | `/login` | `LoginBloc` + `LoginFormCubit` |
| Register | `/register` | `RegisterBloc` + `RegisterFormCubit` |
| Verify Email | `/verify` | `VerifyBloc` |
| Forgot Password | `/forgot-password` | `ForgotPasswordBloc` + `ForgotPasswordFormCubit` |
| Reset Password | `/reset-password` | `ResetPasswordBloc` |
| Agreement | `/agreement` | — |

### Main App (Dashboard)

The `DashboardScreen` hosts an `IndexedStack` with 5 tabs, driven by `NavCubit`.

| Tab | Label | Index | Behaviour |
|-----|-------|-------|-----------|
| Home | Home | 0 | `HomeBloc` — empty state / projects list |
| Discover | Search | 1 | `DiscoverCubit` — search + filter chips |
| **Add** | Add | 2 | **Tapping opens the Create Project wizard** |
| Wallet | Wallet | 3 | Placeholder |
| Profile | Profile | 4 | `ProfileCubit` |

### Create Project Wizard (leader)

Triggered by tapping the **Add** tab. **`CreateProjectCubit`** is at the app root (`main_app.dart`); flow type depends on **category** (saving vs vacation/emergency borrowing vs investment ROI-only vs streamlined).

| Step | Screen | Route | Notes |
|------|--------|-------|--------|
| 0 | **Project Amount** | `AppRoutes.createProjectAmount` | Keypad + amount |
| 1 | **Project Details** | `AppRoutes.createProjectDetails` | Name, description, category, deadline, visibility |
| 2a | **Project Settings** (collaborative saving) | `AppRoutes.createProjectSavingSettings` | Auto-save toggle |
| 2b | **Funds Borrowing** (vacation / emergency) | `AppRoutes.createProjectFundsBorrowing` | Borrow toggle, repayment / penalty when enabled |
| 2c | **Project Settings** (investment) | `AppRoutes.createProjectInvestmentSettings` | Optional ROI field |
| — | *(streamlined)* | — | Details → **Review** (no settings step) |
| 3 | **Review** | `AppRoutes.createProjectReview` | Sections + **Edit** links |
| ✓ | **Project Created** | `AppRoutes.createProjectSuccess` | Share / home |

Step badges (`1/3`, `2/3`, …) are defined in `leader/features/create_project/presentation/create_project_flow.dart` per `ProjectCreationFlowType`.

**"Go to my Project"** uses `context.go(AppRoutes.dashboard)` + `NavCubit.selectTab(0)` to land on Home.

### Profile Flow (sub-routes, full-screen pushed over Dashboard)

| Screen | Route | State |
|--------|-------|-------|
| Edit Profile | `/profile/edit` | `EditProfileCubit` |
| Payment Methods (empty + cards) | `/profile/payment-methods` | `PaymentMethodsCubit` |
| Add Card (custom numpad) | `/profile/payment-methods/add-card` | `AddCardCubit` |
| Card Detail (bottom sheet) | modal | `PaymentMethodsCubit` |
| Transaction History | `/profile/transaction-history` | `TransactionHistoryCubit` |
| Key Guidelines | `/profile/key-guidelines` | — |

---

## Design System

### Color Tokens (`AppColors`)

| Token | Value | Usage |
|-------|-------|-------|
| `primary` | `#4519A0` | Buttons, active states, badges |
| `appBgTop` | `#CEBEFB` | Gradient top (lavender) |
| `appBgBottom` | `#F8F7FA` | Gradient bottom (near-white) |
| `textPrimary` | `#1A0D3D` | Headings, large titles |
| `textBody` | `#443F63` | Body text, labels |
| `authHint` | `#B0ADCA` | Placeholder text |
| `cardBorder` | `#EAE8F2` | Card / field borders |
| `logoutBtn` | `#E53935` | Logout button |
| `txPositive` | `#22C55E` | Income amounts |
| `txNegative` | `#E53935` | Expense amounts |
| `payCardGradientStart` | `#7C3AED` | Card preview gradient |
| `payCardGradientEnd` | `#A78BFA` | Card preview gradient |

### Background Gradient

```dart
AppColors.appBackgroundGradient  // 3-stop: #CEBEFB → #E0D6FC (30%) → #F8F7FA
```

Used on: all auth screens, onboarding, all profile sub-headers, create project headers.

### SVG Assets (`assets/icons/`)

| File | Used in |
|------|---------|
| `home_icon.svg` | Bottom nav |
| `search_icon.svg` | Bottom nav |
| `add_icon.svg` | Bottom nav |
| `wallet_icon.svg` | Bottom nav |
| `profile_icon.svg` | Bottom nav |
| `edit_profile_icon.svg` | Profile settings row |
| `payment_methods_icon.svg` | Profile settings row + empty state |
| `transactionhistory_icon.svg` | Profile settings row |
| `guidelines_icons.svg` | Profile settings row |
| `visacard_icon.svg` | Payment Methods list + Card Preview |
| `mastercard_icon.svg` | Payment Methods list + Card Preview |
| `deposit_icon.svg` | Transaction History |
| `contribution_icon.svg` | Transaction History |
| `dollar-circle.svg` | Transaction History (borrow/lend) |
| `apple.svg` | Login / Register social button |
| `gmail.svg` | Login / Register social button |

### Image Assets (`assets/images/`)

| File | Used in |
|------|---------|
| `logo.svg` | Splash / Auth |
| `onboarding_1-3.png` | Onboarding pages |
| `dashboard_empty_state_image.svg` | Home empty state |
| `project_created_image.svg` | Create Project success screen |

---

## Permissions

### Android (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS (`Info.plist`)

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to set your profile picture.</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take a profile picture.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We save photos to your photo library.</string>
```

---

## Engineering Rules

1. **No hardcoding** — Strings → `AppStrings`, colors → `AppColors`, assets → `AppAssets`, routes → `AppRoutes`; spacing via `AppDimens` / **ScreenUtil** (`.w`, `.h`, `.r`).
2. **State** — Prefer **Cubit** / **Bloc**; **no `setState`** for app logic. **`StatefulWidget`** is OK for controller / focus / animation lifecycle.
3. **File size** — **Target** &lt; 150 lines for new files; split into `widgets/`. Legacy files may be larger—refactor when you touch them.
4. **Validation** — Rules in **`ValidationUtils`**; Cubits call it and store errors on state (see `CreateProjectCubit.validateDetails()`). **No** validation rules copy-pasted in UI widgets.
5. **Common widgets** — `AppButton`, `AppTextField`, `AppText`, etc. from **`lib/core/widgets/common/`**; avoid raw `Text` / `TextField` / `ScaffoldMessenger` in product UI.
6. **`AppTextField`** — Optional `hintStyle`, `suffixIconConstraints` (use tight constraints in **Material 3** so small suffix icons are not forced into a 48×48 visual slot).
7. **SVG** — `flutter_svg` + `ColorFilter.mode(..., BlendMode.srcIn)` where tinting is needed.
8. **Navigation** — `GoRouter` + `AppRoutes` only.
9. **Feedback** — Centralised snackbars / dialogs (`app_snackbar.dart`, shared widgets); user messages from **`AppStrings`**.

Cursor / team checklist: **`.cursor/rules/pre_commit.mdc`**

---

## State Architecture Summary

```
App Root (lib/app/main_app.dart)
└── MultiBlocProvider
    ├── CreateProjectCubit   # leader create-project wizard (all pushed steps)
    └── WalletTransactionCubit

DashboardScreen
└── BlocProvider<NavCubit>
    ├── HomeScreen → MultiBlocProvider[HomeBloc, HomeSectionsCubit]
    ├── DiscoverScreen → BlocProvider<DiscoverCubit>
    └── ProfileScreen → BlocProvider<ProfileCubit>

Pushed routes (profile):
    EditProfileScreen → BlocProvider<ProfileCubit> (fresh) + BlocProvider<EditProfileCubit>
    PaymentMethodsScreen → BlocProvider<PaymentMethodsCubit>
    AddCardScreen → BlocProvider<AddCardCubit>
    TransactionHistoryScreen → BlocProvider<TransactionHistoryCubit>
```
