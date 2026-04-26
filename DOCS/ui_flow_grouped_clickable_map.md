# Vestie UI Flow Map (Grouped + Clickable)

This is a grouped, click-friendly map of the app so you can quickly jump to any section and know:

- where the UI lives
- where the data/state comes from
- how routes connect
- what user vs leader sees

---

## Quick Navigation

- [1. Router Grouping Overview](#1-router-grouping-overview)
- [2. Core Routes (Auth + Entry + Create Wizard)](#2-core-routes-auth--entry--create-wizard)
- [3. Profile & Wallet Routes](#3-profile--wallet-routes)
- [4. Project Routes (User + Leader)](#4-project-routes-user--leader)
- [5. Project Category Mapping](#5-project-category-mapping)
- [6. UI/Data Ownership by Feature](#6-uidata-ownership-by-feature)
- [7. Route Args Contract](#7-route-args-contract)
- [8. File Map (Where to Edit What)](#8-file-map-where-to-edit-what)

---

## 1. Router Grouping Overview

Router is now split into grouped builders:

- **Root:** `lib/app/router/app_router.dart`
- **Core routes:** `lib/app/router/route_groups/core_routes.dart`
- **Profile/Wallet routes:** `lib/app/router/route_groups/profile_wallet_routes.dart`
- **Project routes:** `lib/app/router/route_groups/project_routes.dart`
- **Shared route arg types:** `lib/app/router/route_args/`

This keeps routing maintainable and prevents one giant tightly coupled router file.

---

## 2. Core Routes (Auth + Entry + Create Wizard)

### 2.1 Entry/Auth Flow

Routes:

- `/` -> Splash
- `/onboarding` -> Onboarding
- `/login` -> Login
- `/register` -> Register
- `/verify` -> Verify (email via `extra`)
- `/forgot-password`
- `/reset-password` (email via `extra`)
- `/agreement`
- `/dashboard`
- `/notifications`

UI files:

- Auth pages: `lib/features/auth/presentation/pages/`
- Splash: `lib/features/splash/presentation/pages/splash_screen.dart`
- Onboarding: `lib/features/onboarding/presentation/pages/onboarding_screen.dart`
- Notifications: `lib/features/notifications/presentation/pages/notifications_screen.dart`

Data/state owners:

- Auth blocs/cubits in `lib/features/auth/presentation/`
- Notifications: `NotificationsCubit`

### 2.2 Create Project Wizard

Routes:

1. `/create-project/amount`
2. `/create-project/details`
3. `/create-project/borrowing`
4. `/create-project/review`
5. `/create-project/success`

UI files:

- `lib/features/create_project/presentation/pages/`

Data/state owner:

- `CreateProjectCubit`
- `CreateProjectForm` (`lib/features/create_project/domain/create_project_form.dart`)

---

## 3. Profile & Wallet Routes

### 3.1 Profile Routes

Routes:

- `/profile/edit`
- `/profile/payment-methods`
- `/profile/payment-methods/add-card`
- `/profile/transaction-history`
- `/profile/key-guidelines`

UI files:

- `lib/features/profile/presentation/pages/`
- supporting widgets: `lib/features/profile/presentation/widgets/`

Data/state owners:

- `ProfileCubit`
- payment-related cubits in profile feature

### 3.2 Wallet Transaction Routes

Routes:

1. `/wallet/transaction-amount`
2. `/wallet/select-payment-method`
3. `/wallet/transaction-confirmation`
4. `/wallet/transaction-success`

UI files:

- `lib/features/wallet/presentation/pages/`

Data/state owner:

- `WalletTransactionCubit`

---

## 4. Project Routes (User + Leader)

### 4.1 Project Entry

Entry from cards is centralized in:

- `lib/features/project_detail/presentation/navigation/open_project_from_card.dart`

Normal routes:

- `/project/detail`
- `/project/investment-detail`

Special member result routes:

- `/user/status-flow`
- `/user/success-vote`

### 4.2 Member/User Project Flow

From project detail, user can:

- Contribute -> `/project/contribute`
- Borrow -> `/project/borrow`
- Open member details -> `/project/member-detail`
- View borrow requests -> `/project/borrow-requests` (`isLeaderMode: false`)

UI files:

- `project_detail_screen.dart`
- `investment_project_detail_screen.dart`
- `contribute_flow_screen.dart`
- `borrow_flow_screen.dart`
- `user_status_flow_screen.dart`
- `user_success_vote_screen.dart`

### 4.3 Leader Project Flow

Leader menu actions from project detail:

- Join requests -> `/project/join-requests`
- Create announcement -> `/project/create-announcement`
- Edit project -> `/create-project/details` (`extra: true`)
- Mark successful -> `/project/mark-successful`
- Cancel project -> `/project/cancel`
- Cancel result -> `/project/cancelled`

Also:

- Borrow moderation list -> `/project/borrow-requests` (`isLeaderMode: true`)
- Member action -> `/project/member-penalty-action`

### 4.4 Shared project navigation helpers

To reduce duplication between detail screens:

- `lib/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart`

Provides centralized:

- wallet args builder
- member detail args builder
- borrow request args builder
- leader action router handling

---

## 5. Project Category Mapping

Runtime categories:

- `vacations`
- `emergency`
- `investment`

Shared category behavior is centralized in:

- `lib/features/home/domain/entities/project_category_extensions.dart`

Includes:

- labels
- detail labels
- icon assets
- `isInvestment` logic

Route mapping by category:

- **Investment** -> `/project/investment-detail`
- **Vacations** -> `/project/detail`
- **Emergency** -> `/project/detail`

Category UI locations:

- card chips: `project_card_chip_widgets.dart`
- detail chips: `project_info_card_chips.dart`
- completed copy: `completed_project_notice_copy.dart`

---

## 6. UI/Data Ownership by Feature

### Home

- UI: `lib/features/home/presentation/`
- Data model: `lib/features/home/domain/entities/project.dart`
- Card -> detail route mapping: `open_project_from_card.dart`

### Discover

- UI: `lib/features/discover/presentation/`
- State: `DiscoverCubit`
- Reuses home project card + same project open helper

### Project Detail

- UI: `lib/features/project_detail/presentation/`
- Domain entities: `lib/features/project_detail/domain/entities/`
- Navigation helpers centralized under `presentation/navigation/`

### Contribute / Borrow

- UI: respective `presentation/pages/*_flow_screen.dart`
- State: `ContributeCubit`, `BorrowCubit`
- Shared input widgets under `lib/core/widgets/common/`

### Profile / Wallet

- UI in their feature folders
- Routing grouped under `profile_wallet_routes.dart`

---

## 7. Route Args Contract

### Core/Auth

- `/verify` -> `String email`
- `/reset-password` -> `String email`

### Project detail family

- `/project/detail` and `/project/investment-detail` -> `ProjectDetailRouteArgs`
- `/project/contribute` and `/project/borrow` -> `ProjectWalletFlowArgs`
- `/project/member-detail` -> `MemberDetailRouteArgs`
- `/project/member-penalty-action` -> `MemberEntity`
- `/project/borrow-requests` -> `BorrowRequestsRouteArgs`
- `/project/mark-successful` -> `MarkSuccessfulRouteArgs`
- `/project/cancel` -> `CancelProjectRouteArgs`
- `/project/cancelled` -> `ProjectCancelledRouteArgs`
- `/user/status-flow` -> `UserStatusFlowArgs`
- `/user/success-vote` -> `UserSuccessVoteArgs`

If `extra` type mismatches, router falls back to invalid route screen.

---

## 8. File Map (Where to Edit What)

### Routing

- Main composition: `lib/app/router/app_router.dart`
- Core routes: `lib/app/router/route_groups/core_routes.dart`
- Profile/wallet routes: `lib/app/router/route_groups/profile_wallet_routes.dart`
- Project routes: `lib/app/router/route_groups/project_routes.dart`
- Route args: `lib/app/router/route_args/`

### User vs Leader project behavior

- Project detail UI:  
  `lib/features/project_detail/presentation/pages/project_detail_screen.dart`  
  `lib/features/project_detail/presentation/pages/investment_project_detail_screen.dart`
- Shared leader/user route handling:  
  `lib/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart`

### Category logic

- `lib/features/home/domain/entities/project_category_extensions.dart`

### Flow docs

- Existing comprehensive flow doc: `DOCS/user_leader_flow_all_screens.md`
- This grouped click-map doc: `DOCS/ui_flow_grouped_clickable_map.md`

