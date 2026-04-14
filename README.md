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

## Architecture

```
lib/
├── app/
│   ├── main_app.dart            # MultiBlocProvider root + MaterialApp.router
│   └── router/
│       ├── app_router.dart      # GoRouter with all routes
│       └── app_routes.dart      # Route constants (never use raw strings)
│
├── core/
│   ├── constants/
│   │   ├── app_assets.dart      # All asset paths (SVG + PNG)
│   │   ├── app_strings.dart     # Every user-visible string
│   │   └── app_dimens.dart      # Spacing / radius constants
│   ├── theme/
│   │   ├── app_colors.dart      # Full palette + LinearGradient constants
│   │   └── app_theme.dart       # ThemeData
│   ├── utils/
│   │   ├── app_snackbar.dart    # Centralised success / error / info toasts
│   │   └── validation_utils.dart
│   └── widgets/common/          # AppButton, AppTextField, AppText, AppLoader …
│
└── features/
    ├── splash/
    ├── onboarding/
    ├── auth/
    ├── dashboard/
    ├── home/
    ├── discover/
    ├── create_project/          # ← 5-step project wizard
    └── profile/                 # ← full profile + payment + transactions
```

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

### Create Project Wizard (5 steps)

Triggered by tapping the **Add** tab. All steps share one `CreateProjectCubit` provided at the app root (`main_app.dart`), so state persists across pushed routes.

| Step | Screen | Route | Badge |
|------|--------|-------|-------|
| 0 | **Project Amount** — numeric keypad, `$240.00` display, purple Continue | `/create-project/amount` | — |
| 1 | **Project Details** — name, description, category dropdown, date picker, Public/Private toggle | `/create-project/details` | `1/3` white |
| 2 | **Borrowing** — ROI field + info icon, dashed divider, enable-borrowing toggle, limit / window / penalty | `/create-project/borrowing` | `2/3` white |
| 3 | **Review** — 4 section cards (Project Details, Description & Rules, Borrowing, ROI) each with inline **Edit** | `/create-project/review` | `4/4` green |
| ✓ | **Project Created** — full gradient, SVG badge, share link + copy, WhatsApp deep-link, "Go to my Project" → Home | `/create-project/success` | — |

**"Go to my Project"** calls `context.go(AppRoutes.dashboard)` + `NavCubit.selectTab(0)` to land on the Home tab.

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

1. **No hardcoding** — All strings → `AppStrings`, all colors → `AppColors`, all paths → `AppAssets`, all sizes → `AppDimens` / screenutil
2. **No `setState`** — UI state via `Cubit`; business logic via `Bloc`; all widgets are `StatelessWidget` or minimal `StatefulWidget` (controller lifecycle only)
3. **File size < 150 lines** — Large screens split into sub-widgets in `widgets/` directories
4. **Validation in `ValidationUtils`** — Never inside UI widgets or Bloc/Cubit
5. **Common widgets** — `AppButton`, `AppTextField`, `AppText`, `AppLoader`, `AppSnackBar` used everywhere; no raw `Text()`, `TextField()`, or `ScaffoldMessenger` calls
6. **SVG icons** via `flutter_svg` with `ColorFilter.mode(color, BlendMode.srcIn)` tinting
7. **Navigation** via `GoRouter` + `AppRoutes` constants only — no raw string paths
8. **Snackbars** — `AppSnackBar.showSuccess/showError/showInfo` only (Rule 21)

---

## State Architecture Summary

```
App Root (main_app.dart)
└── MultiBlocProvider
    └── CreateProjectCubit (wizard persists across all pushed routes)

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
