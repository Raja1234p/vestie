# Vestie — Feature Map

Quick index for onboarding: **where code lives**, **primary APIs**, **entry routes**.

> Paths use `AppRoutes` constants. Full route table: `lib/app/router/app_routes.dart`.

---

## Auth & bootstrap

| Feature | Code location | Key APIs | Entry |
|---------|---------------|----------|-------|
| Splash | `features/splash/` | Session read | `/` |
| Onboarding | `features/onboarding/` | Local prefs | `/onboarding` |
| Login / Register | `features/auth/` | `POST /auth/*` | `/login`, `/register` |
| Verify email | `features/auth/` | `POST /auth/verify` | `/verify` |
| Agreement | `features/auth/` | `GET/POST /users/me/risk-disclaimer` | `/agreement` |

**Trace:** `LoginScreen` → `LoginBloc` → `LoginUseCase` → `AuthRepository` → `AuthRemoteDataSource`

---

## Dashboard

| Tab | Code | API | Route |
|-----|------|-----|-------|
| Home | `user/features/home/` | `GET /projects?scope=mine` | `/dashboard` tab 0 |
| Discover | `user/features/discover/` | `GET /projects?scope=discover` | tab 1 |
| Create (+) | `leader/features/create_project/` | `POST /projects`, launch | wizard routes |
| Wallet | `features/wallet/` | `GET /wallet` | tab 3 |
| Profile | `features/profile/` | `GET /users/me` | tab 4 |

---

## Projects & invites

| Feature | Location | APIs | Navigation |
|---------|----------|------|------------|
| List / join | `features/projects/` | list, join | Home, Discover |
| Invite preview | `features/invites/` | preview invite | `/join/:inviteCode` |
| Project detail | `features/project_detail/` | `GET /projects/{id}` | `/project/detail` |
| Investment detail | `user/features/project_detail/` | same + investment UI | `/project/investment-detail` |
| Detail navigation | `features/project_detail/presentation/navigation/project_detail_navigation.dart` | — | push helpers |

---

## Money flows

| Feature | Location | APIs |
|---------|----------|------|
| Wallet | `features/wallet/` | `/wallet` |
| Deposit | `features/wallet/` | deposit intent, Stripe |
| Withdraw | `features/wallet/` | preview + withdraw |
| Payment methods | `features/payment_methods/` | Stripe SetupIntent |
| KYC | `features/kyc/` | `/kyc/*` |
| Bank accounts | `features/bank_accounts/` | link, list |
| Stripe config | `features/stripe/` | config endpoint |
| Contribute | `user/features/contributions/` | `POST /projects/{id}/contributions` |
| Borrow | `user/features/borrow/` | borrow-requests APIs |
| Project pot | `features/project_pot/` | `GET /projects/{id}/pot` |

**Trace (contribute):** `ContributeFlowScreen` → `ContributeBloc` → `ConfirmContributionUseCase` → `ContributionRepository`

---

## Leader moderation

| Feature | Location | APIs |
|---------|----------|------|
| Create wizard | `leader/features/create_project/` | create + launch |
| Join requests | `leader/features/project_detail/` | pending join, approve/reject |
| Borrow approvals | `leader/features/project_detail/` | approve/reject borrow |
| Voting | `features/project_detail/` (voting bloc) | vote APIs |
| Announcements | `features/project_announcements/` | create/delete |
| Distribute funds | `leader/features/project_detail/` | investment distribution |

---

## VFF (social)

| Feature | Location | APIs | Routes |
|---------|----------|------|--------|
| Hub | `user/features/vff/` | `/users/me/vffs`, inbox | `/user/vff` |
| Profile | `user/features/vff/` | profile endpoints | `/user/vff/profile` |
| Invites sent | `user/features/vff/` | invite APIs | `/user/vff/invite-success` |

---

## Notifications

| Feature | Location | APIs |
|---------|----------|------|
| In-app list | `features/notifications/` | list, mark read |
| FCM | `core/services/fcm_push_service.dart` | register device token |

---

## UI-only (no live project API)

| Feature | Location | Notes |
|---------|----------|-------|
| Member fund storyboard | `user/features/create_project_member_fund/` | `CreateProjectFundDraft` via `extra` |
| Some investment snapshots | `user/features/investment/` | partial mocks |

---

## Role → folder guide

| If you are changing… | Start in |
|---------------------|----------|
| Something all users see | `lib/features/` |
| Member-only tab/flow | `lib/user/features/` |
| Leader / co-leader tools | `lib/leader/features/` |
| Shared UI / API / DI | `lib/core/` |
| Routes | `lib/app/router/` |
