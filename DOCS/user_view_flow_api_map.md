# User View Flow + API Map

This document is a practical map of the **member/user-side** experience: which screens connect to which, what route args are required, and what API endpoints you will likely wire per step.

## 1) Entry + Auth

- `/` (`SplashScreen`)
  - decides whether to open onboarding/auth/dashboard.
- `/onboarding` (`OnboardingScreen`)
  - CTA -> `/login` or `/register`.
- `/login` (`LoginScreen`)
  - success -> `/dashboard`
  - forgot password -> `/forgot-password`
- `/register` (`RegisterScreen`)
  - success -> `/verify` with `extra: email`
- `/verify` (`VerifyScreen`)
  - success -> `/agreement`
- `/agreement` (`AgreementScreen`)
  - continue -> `/dashboard`

### API to integrate
- `POST /auth/login`
- `POST /auth/register`
- `POST /auth/verify-otp`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`
- `POST /auth/accept-guidelines`
- `GET /me/session` (used by splash bootstrap)

---

## 2) Dashboard (User tabs)

Route: `/dashboard` (`DashboardScreen`, indexed tabs)

- Tab 0 Home (`HomeScreen`)
- Tab 1 Discover (`DiscoverScreen`)
- Tab 2 Add (opens create project wizard; typically leader-oriented)
- Tab 3 Wallet (`WalletScreen`)
- Tab 4 Profile (`ProfileScreen`)

### API to integrate
- `GET /me/summary`
- `GET /projects/my`
- `GET /projects/joined`
- `GET /projects/discover`

---

## 3) Opening project detail as a user

From Home/Discover cards -> `openProjectFromCard(...)`:

1. For special member demo states, it opens:
   - `/user/status-flow` with `UserStatusFlowArgs`, or
   - `/user/success-vote` with `UserSuccessVoteArgs`
2. Otherwise, normal detail opens:
   - `/project/detail` with `extra: ProjectDetailRouteArgs(project)`
   - or `/project/investment-detail` with same `extra`

### API to integrate
- `GET /projects/{projectId}`
- `GET /projects/{projectId}/announcements`
- `GET /projects/{projectId}/members`
- `GET /projects/{projectId}/borrow-requests`
- `GET /projects/{projectId}/member-state` (join status, vote state, penalties)

---

## 4) User actions inside Project Detail

From `ProjectDetailScreen` / `InvestmentProjectDetailScreen`:

- Contribute -> `/project/contribute`
  - required `extra: ProjectWalletFlowArgs`
- Borrow -> `/project/borrow`
  - required `extra: ProjectWalletFlowArgs`
- Member card tap -> `/project/member-detail`
  - required `extra: MemberDetailRouteArgs`
- Borrow requests list -> `/project/borrow-requests`
  - required `extra: BorrowRequestsRouteArgs(isLeaderMode: false)`

### API to integrate
- `POST /projects/{projectId}/contributions`
- `POST /projects/{projectId}/borrow-requests`
- `GET /projects/{projectId}/borrow-requests?mine=true`
- `GET /projects/{projectId}/members/{memberId}`

---

## 5) Contribute flow (member)

Route: `/project/contribute` (`ContributeFlowScreen`)

State steps:
- amount -> confirm -> success

Important fields:
- amount digits + computed fee
- payment source wallet
- non-refundable acceptance

### API to integrate
- `POST /projects/{projectId}/contributions/quote` (optional; returns fee/total)
- `POST /projects/{projectId}/contributions/confirm`
- `GET /wallet/balance` (for wallet pill)

---

## 6) Borrow flow (member)

Route: `/project/borrow` (`BorrowFlowScreen`)

State steps:
- amount (+ note) -> terms confirm -> success

Important fields:
- borrow amount
- note/reason
- terms acceptance
- borrow limit and due-by label from flow args/back-end

### API to integrate
- `POST /projects/{projectId}/borrow-requests/quote` (optional validations)
- `POST /projects/{projectId}/borrow-requests`
- `GET /projects/{projectId}/borrow-policy` (limit, due window, penalties)

---

## 7) Wallet flow (member)

Routes:
- `/wallet/transaction-amount`
- `/wallet/select-payment-method`
- `/wallet/transaction-confirmation`
- `/wallet/transaction-success`

### API to integrate
- `GET /wallet`
- `GET /wallet/payment-methods`
- `POST /wallet/deposit-intent`
- `POST /wallet/withdraw-intent`
- `POST /wallet/transactions/confirm`
- `GET /wallet/transactions`

---

## 8) Profile flow (member)

Routes:
- `/profile/edit`
- `/profile/payment-methods`
- `/profile/payment-methods/add-card`
- `/profile/transaction-history`
- `/profile/key-guidelines`

### API to integrate
- `GET /me/profile`
- `PATCH /me/profile`
- `GET /wallet/payment-methods`
- `POST /wallet/payment-methods`
- `PATCH /wallet/payment-methods/{id}/primary`
- `DELETE /wallet/payment-methods/{id}`
- `GET /wallet/transactions?filters=...`

---

## 9) Route extras contract (must keep stable)

- `/project/detail`, `/project/investment-detail`
  - `ProjectDetailRouteArgs`
- `/project/contribute`, `/project/borrow`
  - `ProjectWalletFlowArgs`
- `/project/member-detail`
  - `MemberDetailRouteArgs`
- `/project/borrow-requests`
  - `BorrowRequestsRouteArgs`
- `/user/status-flow`
  - `UserStatusFlowArgs`
- `/user/success-vote`
  - `UserSuccessVoteArgs`

If these models change, update both router and caller side together.

---

## 10) Suggested API integration order (user side)

1. Auth + agreement
2. Dashboard/home/discover list APIs
3. Project detail API
4. Contribute API
5. Borrow API
6. Wallet transaction APIs
7. Profile + payment methods
8. User status/vote result endpoints

