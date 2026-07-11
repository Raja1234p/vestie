# Vestie — App Guide (roles, flows & code map)

**Audience:** Engineers, QA, and product reviewing how Vestie works end-to-end.  
**Last updated:** July 2026  
**Rule:** All navigation uses `AppRoutes` + typed `GoRouter` extras — never raw path strings in widgets.

---

## 1. What Vestie is

Vestie is a **collaborative group savings** Flutter app (Android & iOS). Users create or join **projects** (vacation, emergency, investment), contribute from a **wallet**, borrow from group pots (vacation/emergency only), vote on project outcomes, pay via **Stripe**, connect via **VFF**, and complete **KYC** for withdraw.

Vestie is **not a bank** — risk disclaimers are required; leaders set repayment terms for borrows.

**Product scope:** [`DOCS/project_scope.md`](DOCS/project_scope.md)

---

## 2. Roles & permissions

| Role | API `viewerRole` / `userRole` | Code folder | What they can do |
|------|------------------------------|-------------|------------------|
| **Group Leader** | `GroupLeader` / `leader` | `lib/leader/features/` | Create projects (+ tab), approve join/borrow, start votes, cancel project, distribute investment funds, announcements |
| **Co-Leader** | `CoLeader` / `co_leader` | Shared detail + leader moderation where permitted | Vacation/emergency only — co-manage members, votes, borrow decisions |
| **Member** | `Member` / `member` | `lib/user/features/` | Home/Discover, contribute, borrow (vacation/emergency), cast closure votes, VFF, wallet |
| **Shared (all roles)** | — | `lib/features/`, `lib/core/`, `lib/app/` | Auth, wallet, profile, invites, project detail shell, notifications |

### Project categories

| Category | Borrow | Co-leader | Detail route | Notes |
|----------|--------|-----------|--------------|-------|
| Vacation | Yes | Yes | `/project/detail` | Success vote + refund paths |
| Emergency | Yes | Yes | `/project/detail` | Same as vacation |
| Investment | No | No | `/project/investment-detail` | Stop-contrib vote → distribute funds → final closure vote |

### Join visibility

| Visibility | Join result | UX |
|------------|-------------|-----|
| **Public** | `status: active` | Immediate membership → project detail |
| **Private** | `status: pending` | Request sent → leader approves in join requests |

---

## 3. Code layout (where to edit)

```text
lib/
├── main.dart, bootstrap.dart          # Entry (production: main.dart)
├── app/
│   ├── main_app.dart                  # ScreenUtil, global providers
│   └── router/
│       ├── app_routes.dart            # ALL route path constants
│       ├── app_router.dart
│       └── route_groups/              # core_routes, project_routes, profile_wallet_routes, …
├── core/
│   ├── constants/                     # AppStrings, AppColors, ApiConstants, AppAssets
│   ├── di/                            # ServiceLocator, inject_*.dart
│   ├── network/                       # BaseApiClient, Dio
│   ├── stripe/                        # PaymentSheet wrapper
│   ├── realtime/                      # SignalR (wallet, projects)
│   └── widgets/common/                # AppButton, AppToast, AppSuccessScreen, …
├── features/                          # Shared modules (all roles)
│   ├── auth/, splash/, onboarding/, dashboard/
│   ├── projects/, invites/, project_detail/, project_pot/
│   ├── wallet/, kyc/, bank_accounts/, payment_methods/, stripe/
│   ├── profile/, notifications/
│   └── success_vote/                  # Vote cast + outcome screens
├── leader/features/
│   ├── create_project/                # Leader wizard (+ tab)
│   └── project_detail/                # Join/borrow moderation, voting monitor, distribute
└── user/features/
    ├── home/, discover/
    ├── contribute/, contributions/, borrow/
    ├── project_detail/                # Member vote UI overlays
    ├── investment/, vff/
    └── create_project_member_fund/    # UI storyboard only (no API)
```

| Need | Start here |
|------|------------|
| Route constant | `lib/app/router/app_routes.dart` |
| Register a screen | `lib/app/router/route_groups/*.dart` |
| Feature index | [`FEATURE_MAP.md`](FEATURE_MAP.md) |
| Step-by-step traces | [`PROJECT_FLOW_MAP.md`](PROJECT_FLOW_MAP.md) |
| DI / use cases | [`DEPENDENCY_MAP.md`](DEPENDENCY_MAP.md) + `lib/core/di/inject_*.dart` |
| Per-feature notes | `feature_overview.md` in each feature folder |
| API ↔ screen refresh rules | [`DOCS/qa/api_screen_sync_matrix.md`](DOCS/qa/api_screen_sync_matrix.md) |

---

## 4. App bootstrap & auth

```text
/ (SplashScreen)
  SplashCubit → token + onboarding + pending invite
    ├─ pending invite + authed     → /join/:inviteCode
    ├─ authed + disclaimer OK      → /dashboard
    ├─ authed + no disclaimer      → /agreement
    ├─ not authed + onboarding done → /login
    └─ first launch                → /onboarding → /login

Login / Register → Verify → Agreement (if needed) → /dashboard
```

| Screen | Route | State | Key files |
|--------|-------|-------|-----------|
| Splash | `/` | `SplashCubit` | `lib/features/splash/` |
| Onboarding | `/onboarding` | `OnboardingCubit` | `lib/features/onboarding/` |
| Login | `/login` | `LoginBloc` | `lib/features/auth/` |
| Register | `/register` | `RegisterBloc` | `lib/features/auth/` |
| Verify email | `/verify` | `VerifyEmailCubit` | `lib/features/auth/` |
| Agreement | `/agreement` | — | `POST /users/me/risk-disclaimer` |

**Session:** tokens in secure storage; `AppAuthSession` refreshes GoRouter on login/logout.

---

## 5. Dashboard (post-auth hub)

`DashboardScreen` (`/dashboard`) — `IndexedStack` + `NavCubit`:

| Tab | Index | Screen | Primary API | Folder |
|-----|-------|--------|-------------|--------|
| Home | 0 | `HomeScreen` | `GET /projects?scope=mine` | `lib/user/features/home/` |
| Discover | 1 | `DiscoverScreen` | `GET /projects?scope=discover` | `lib/user/features/discover/` |
| **+** | 2 | Leader create sheet | `POST /projects` + launch | `lib/leader/features/create_project/` |
| Wallet | 3 | `WalletScreen` | `GET /wallet` | `lib/features/wallet/` |
| Profile | 4 | `ProfileScreen` | `GET /users/me` | `lib/features/profile/` |

Header shortcuts: **Notifications** → `/notifications`, **VFF** → `/user/vff`.

---

## 6. Project flows

### 6.1 Leader — create project

```text
+ tab → amount → details → settings branch → review → POST /projects + launch
  → /create-project/success → dashboard → push project detail
```

| Step | Route | Files |
|------|-------|-------|
| Amount | `AppRoutes.createProjectAmount` | `leader/features/create_project/presentation/` |
| Details | `createProjectDetails` | `CreateProjectCubit` (provided at `MainApp`) |
| Settings | saving / borrowing / investment branch | `create_project_flow.dart` |
| Review | `createProjectReview` | `CreateProjectReviewScreen` |
| Success | `createProjectSuccess` | `create_project_success_screen.dart` |

### 6.2 Member — join a project

| Source | API body | Success UX | Files |
|--------|----------|------------|-------|
| Home / Discover | `projectId` | Public → detail; private → request sent | `lib/features/projects/`, `open_project_from_card.dart` |
| Invite link `/join/:code` | `inviteCode` | Public → joined success → detail | `lib/features/invites/` |
| VFF | VFF then join | Hub → join | `lib/user/features/vff/` |

Deep links: `vestie://join/{code}`, HTTPS invite host — `ProjectInviteDeepLinkService`.

### 6.3 Project detail (live)

```text
openProjectFromCard / openProjectDetailById
  → /project/detail  (vacation/emergency)
  → /project/investment-detail  (investment)
  ProjectDetailBloc → GET /projects/{id}
  (+ GET /pot, borrow supplement, closure vote probe — unless read-only completed profile)
```

| File | Role |
|------|------|
| `lib/features/project_detail/presentation/pages/project_detail_screen.dart` | Vacation/emergency shell |
| `lib/user/features/project_detail/presentation/pages/investment_project_detail_screen.dart` | Investment shell |
| `lib/features/projects/presentation/bloc/project_detail_bloc.dart` | Load + refresh |
| `lib/features/project_detail/presentation/navigation/project_detail_navigation.dart` | Push contribute, borrow, members, leader actions |

---

## 7. Voting flow (closure / success vote)

Voting decides whether a vacation/emergency project succeeded, whether investment contributions stop, or final investment closure.

### 7.1 Vote types (API `voteType`)

| `voteType` | Used for |
|------------|----------|
| `SuccessVote` | Vacation/emergency — mark project successful |
| `StopContributionsVote` | Investment — close contributions phase |
| `FinalClosureVote` | Investment — final mark successful / dispute |

### 7.1 Outcomes (API `outcome`)

`Success` · `InvestmentStarted` · `Refund` · `Disputed` · `NoVotes`

**Backend contract:** [`DOCS/outcome.md`](DOCS/outcome.md) · [`DOCS/backend_handoff_project_detail_voting_api.md`](DOCS/backend_handoff_project_detail_voting_api.md)

### 7.2 Member / co-leader — cast vote (inline on detail)

```text
GET /projects/{id}  →  voting, votingStatus, memberVotes[]
  votingStatus == pending && !hasVoted
    → ProjectDetailInlineCastVote
    → POST …/closure-voting/vote
    → reload detail
    → ProjectDetailInlineVoteSubmitted (tallies + Back to Home)
```

| File | Purpose |
|------|---------|
| `lib/features/project_detail/presentation/widgets/` (inline cast/post-vote) | Detail takeover UI |
| `lib/features/success_vote/presentation/pages/success_vote_cast_screen.dart` | Routed fallback cast |
| `lib/features/success_vote/presentation/cubit/success_vote_cast_cubit.dart` | Cast POST |
| `lib/features/project_detail/data/models/closure_voting_response_model.dart` | Parse vote envelope |

### 7.3 Leader — monitor votes

```text
Project detail menu → View Success Votes
  → GET /projects/{id} (voting + memberVotes[])
  → legacy fallback: GET …/closure-voting/active
```

Files: `lib/leader/features/project_detail/` (monitor screens, decision dialogs).

**Finalize:** backend cron auto-finalizes after deadline — app does **not** call finalize; refresh detail to see completed state.

### 7.4 Full-screen outcome (after vote finalized / completed project)

```text
showsCompletedProjectVoteOutcome on ProjectDetailEntity
  → SuccessVoteOutcomeScreen (approved / rejected / no-votes variants)
```

| File | Purpose |
|------|---------|
| `lib/features/success_vote/presentation/pages/success_vote_outcome_screen.dart` | Outcome UI |
| `lib/features/success_vote/presentation/pages/success_vote_outcome_load_screen.dart` | GET detail then outcome |
| `lib/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart` | API → UI args |
| `lib/features/success_vote/presentation/navigation/open_success_vote_outcome.dart` | Navigation helpers |

### 7.5 Investment vote phases (summary)

| Phase | When | UI |
|-------|------|-----|
| Stop contributions vote in progress | `StopContributionsVote` pending | Inline cast on investment detail |
| Stop contributions **approved** | Contributions closed | **Distribute Funds** / **Investment Returns** on detail (not outcome screen) |
| Stop contributions **rejected** | Vote failed | Full-screen `SuccessVoteOutcomeScreen` |
| Final closure vote | `FinalClosureVote` | Inline cast; completed → outcome or stay on detail per dispute rules |
| No votes (vacation/emergency) | `NoVotes` outcome | Full-screen no-votes outcome |

### 7.6 Completed projects profile flow (isolated)

```text
Profile → Completed Projects → View
  → SuccessVoteOutcomeLoadScreen (GET /projects/{id})
  → SuccessVoteOutcomeScreen  [fromCompletedProjectsList: true]
      Back button → completed list
      View Details → read-only project detail (skipCompletedOutcomeTakeover)
```

| File | Purpose |
|------|---------|
| `lib/features/profile/presentation/navigation/open_completed_project_detail.dart` | Entry |
| `lib/features/profile/presentation/pages/completed_projects_screen.dart` | List |
| `lib/features/project_detail/presentation/widgets/completed_projects_profile_detail_content.dart` | Read-only detail body |
| `lib/features/projects/presentation/bloc/project_detail_bloc.dart` | `completedProjectsProfileReadOnly` skips pot/active vote/borrow |

This flow does **not** affect Home, Discover, or normal project detail.

---

## 8. Money flows

### 8.1 Wallet

| Action | Route / entry | API | Files |
|--------|---------------|-----|-------|
| View balance | Wallet tab | `GET /wallet` | `lib/features/wallet/` |
| Deposit | Wallet → deposit | `POST /wallet/deposit/intent` + Stripe PaymentSheet | `deposit_*` screens |
| Withdraw | Wallet → withdraw | preview + `POST /wallet/withdrawals` | `withdraw_*` screens |
| Realtime | SignalR | `/hubs/wallet` | `wallet_signalr_service.dart` |

**Gates:** risk disclaimer; withdraw requires KYC + linked bank.

### 8.2 Contribute

```text
Project detail → /project/contribute
  ContributeBloc → POST /projects/{id}/contributions
  Success → refresh project detail + wallet
```

Files: `lib/user/features/contribute/`, `lib/user/features/contributions/`.

### 8.3 Borrow (vacation / emergency only)

```text
/project/borrow → amount → confirm → POST borrow-requests
  Leader approve/reject → member My Borrow → repay flow
```

Files: `lib/user/features/borrow/` (reference implementation per architecture rules).

Key sync: project detail reload **before** success UI after borrow POST/cancel/repay (`BorrowProjectDetailSync`).

### 8.4 Payment methods & Stripe

Profile → Payment Methods; contribute/deposit payment pickers.  
Files: `lib/features/payment_methods/`, `lib/core/stripe/`, `lib/features/stripe/`.

### 8.5 KYC & bank link

Browser onboarding with return URLs `vestie://kyc/*`, `vestie://bank/*` (app_links, not GoRouter).  
Files: `lib/features/kyc/`, `lib/features/bank_accounts/`.

---

## 9. Other flows

### 9.1 VFF (Vestie Friends & Family)

`/user/vff` hub — connections, inbox, profile, invite success.  
Files: `lib/user/features/vff/`.

### 9.2 Notifications & push

In-app: `/notifications` — `GET /notifications`, mark-read on tap.  
FCM: `lib/core/services/fcm_push_service.dart` → `push_notification_router.dart`.  
See [`DOCS/push_notification_routing.md`](DOCS/push_notification_routing.md).

### 9.3 Profile sub-routes

| Screen | Route | API |
|--------|-------|-----|
| Edit profile | `/profile/edit` | `PATCH /users/me` |
| Payment methods | `/profile/payment-methods` | Stripe SetupIntent |
| My accounts (banks) | `/profile/my-accounts` | `GET /bank-accounts` |
| Transaction history | `/profile/transaction-history` | `GET /wallet/transactions` |
| Completed projects | `/profile/completed-projects` | `GET /projects/completed` |
| Delete account | Profile ⋯ menu | `GET /account/deletion-eligibility` → `POST /account/delete` |

### 9.4 UI-only (no live project API)

| Feature | Folder | Notes |
|---------|--------|-------|
| Member fund storyboard | `lib/user/features/create_project_member_fund/` | `CreateProjectFundDraft` via route `extra` |
| Some `userFlow` card shortcuts | Home cards | Design overlays — not production API paths |
| Partial investment snapshots | `lib/user/features/investment/` | Some mock UI |

---

## 10. Layer pattern (every API feature)

```text
Screen → Cubit/Bloc → UseCase → Repository → RemoteDataSource → BaseApiClient
```

- **No widgets → Dio** — repositories only.
- **No magic strings** — `AppStrings`, `ApiConstants`, `AppRoutes`; API statuses parsed in models/entities.
- **Loading:** shimmer (initial load), `AppButton.isLoading` (footer POST), `AppActionDialog.showAsync` (dialogs).
- **Errors:** `AppErrorView` + retry (load fail); `AppToast` (action fail).

Rules: `.cursor/rules/architecture.mdc`, `.cursor/rules/pre_commit.mdc`.

---

## 11. Route groups index

| File | Covers |
|------|--------|
| `lib/app/router/route_groups/core_routes.dart` | Splash, auth, dashboard, notifications, leader create, invite |
| `lib/app/router/route_groups/profile_wallet_routes.dart` | Profile, wallet, KYC, bank |
| `lib/app/router/route_groups/project_routes.dart` | Detail, contribute, borrow, votes, leader moderation |
| `lib/app/router/route_groups/create_project_member_flow_routes.dart` | Member storyboard (UI only) |
| `lib/app/router/route_groups/user_vff_routes.dart` | VFF hub |

---

## 12. Documentation map (what to read when)

| Task | Document |
|------|----------|
| **Start here (this file)** | `APP_GUIDE.md` |
| 30-min architecture | `ARCHITECTURE_OVERVIEW.md` |
| Flow traces (8 journeys) | `PROJECT_FLOW_MAP.md` |
| Feature → folder → API | `FEATURE_MAP.md` |
| Extended routes & join paths | `DOCS/architecture_flows.md` |
| Member vacation/emergency screens | `DOCS/group_vacation_emergency_member_flow.md` |
| API integration & weeks | `DOCS/api_integration_plan.md` |
| QA before release | `DOCS/qa/README.md` → manual runbook |
| API refresh matrix | `DOCS/qa/api_screen_sync_matrix.md` |
| Vote outcome backend contract | `DOCS/outcome.md` |
| Engineering rules (AI/team) | `.cursor/rules/*.mdc` |

---

## 13. Pre-release checklist (audit snapshot — July 2026)

**No code changes in this section** — track remaining work before store release.

### P0 — Must verify on device

| Item | Status | Reference |
|------|--------|-----------|
| `flutter analyze` (0 errors) + `flutter test` + release APK | Run before each release | `production_scope.mdc` |
| Full manual runbook on physical device | **Required** | `DOCS/qa/manual_test_runbook.md` |
| Week 4 → 5 → 7 QA checklists | **Required** | `DOCS/qa/week_4_qa.md`, `week_5_qa.md`, `week_7_qa.md` |
| **Contribute** end-to-end (wallet debit, pot update) | Often still open | `DOCS/qa/final_audit_remaining_tests.md` §P0 |
| **Withdraw** Standard + Instant variants | Verify if only one tested | same |
| **Risk disclaimer** gates deposit/withdraw/contribute | Verify fresh user | same |
| **Delete account** eligibility + delete POST | New flow — device QA | `lib/features/profile/` |
| **Completed projects** outcome → back → View Details → back | Profile flow QA | `APP_GUIDE.md` §7.6 |
| **Voting** cast → post-vote → finalize → outcome (vacation + investment) | Backend + app sync | `DOCS/outcome.md` |
| Confirm **API base URL** matches production host | Config check | `lib/core/constants/api_constants.dart` |

### P1 — Should verify

| Item | Notes |
|------|-------|
| Announcements create/list/delete (leader) | Week 7 |
| Notifications inbox + mark-read | Week 7 |
| Contribute with insufficient wallet → deposit path | Week 4 |
| Borrow full cycle: request → approve → repay | Week 8 matrix |
| SignalR pot refresh (two devices) | Week 4 |
| FCM push delivery + tap routing | Ops + device |
| Stripe **live** keys on production backend | Not test cards |

### P2 — Known gaps / polish (documented, not blockers)

| Item | Source |
|------|--------|
| `AppRoutes.cardDetail` not registered in GoRouter | `DOCS/architecture_flows.md` §17 |
| FCM → named-route deep navigation incomplete | same |
| Stripe Connect onboarding not integrated | `api_screen_sync_matrix.md` Week 5 |
| Simulated deposit endpoint not in app flow | same |
| Member fund storyboard + some investment UI — **UI-only** | `FEATURE_MAP.md` |
| Folder migration (~794 files) **deferred** | `.cursor/rules/production_scope.mdc` |
| Fallback mock data on wallet/payment/notifications API fail — audit for release | `api_screen_sync_matrix.md` §Fallback |

### Sign-off

Use tables in [`DOCS/qa/production_readiness_review.md`](DOCS/qa/production_readiness_review.md) for formal Week 4/5/7 sign-off (mobile, QA, backend, product).
