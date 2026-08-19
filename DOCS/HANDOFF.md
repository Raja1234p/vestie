# Vestie — E2E handoff (new chat resume)

**Audience:** Next Cursor chat / engineer with **no memory** of prior sessions.  
**Last updated:** 2026-08-19 (VFF dot badge + UI polish)  
**Branch:** `final-changes`  
**Mode:** production-hardening (stability over refactors)

This file is the **session resume**. Read it **before any work**. Then follow `.cursor/rules/architecture.mdc` for every code change.

---

## 0. Mandatory start (every new chat, every task)

Read **in this order**:

1. **This file** — `DOCS/HANDOFF.md`
2. `.cursor/rules/agent_workflow.mdc`
3. `.cursor/rules/architecture.mdc` — layers, no magic strings, post-action sync
4. `.cursor/rules/production_scope.mdc` — what is allowed vs deferred
5. `.cursor/rules/pre_commit.mdc` — Cubit, `AppStrings`, `AppToast`, ScreenUtil
6. `.cursor/rules/project_context.mdc` — product, roles, must-not-break flows
7. For the feature you touch: that folder’s `feature_overview.md`

Then use the doc map in §8. **Do not skip architecture.** Presentation never calls Dio / `ApiConstants`.

---

## 1. Current snapshot (resume here)

### Shipped on `final-changes` (do not re-do)

| Item | Commit / notes |
|------|----------------|
| **Total Members** | `6bcce36` — list + detail use `totalJoinedMember` only. `0`/null **hides** the row. `memberCount` is **voting only**. |
| **Continue contribution** | `2a424c3` — Group Leader monitor footer. `POST …/closure-voting/cancel` with `{}`. Then `GET /projects/{id}` is source of truth. |
| **Stripe Deposit Fee** label | `691c426` — `AppStrings.walletDepositFeeLabel` |
| **Notification unread bell badge** | `321ee8a` — Home + Discover bell count pill (`1`…`99+`) via `NotificationUnreadCubit` + `GET /notifications` probe (`pageSize: 1`). Refresh: dashboard open, app resume, FCM foreground/tap, inbox sync, pop from notifications; reset on logout. |
| **VFF pending dot badge** | `01a708b` + `3a2ff5b` — 12×12 purple dot on VFF (heart) icon. `VffPendingCubit` (app-level) + `VffPendingRefresh` bridge. Dot shows when `GET /vff/received-inbox` returns non-empty requests or project invites. Refresh: dashboard open, app resume, FCM `VffRequestReceived`, hub inbox load/mutate; clear on accept/decline all + logout. Bell–heart gap 12w. |
| Product tours / FCM join-request routing | `68947be` |

### Continue contribution (live contract)

- **Who:** GroupLeader only (never member / co-leader).
- **Where:** `LeaderViewSuccessVotesScreen` pinned footer only (not project-detail wallet row).
- **Show when:** vote open AND `votesCast * 2 < totalJoinedMember` AND `voting.canContinueContributions != false`. Hide at exactly 50%.
- **API:** `POST /api/v1/projects/{projectId}/closure-voting/cancel` · Bearer · body `{}`
- **200:** `{ cancelled, projectId, votingStatus: "not_started" }` → reload GET detail → pop monitor.
- **Errors:** 403 `Forbidden` · 404 `NoOpenVote` · 409 `VoteParticipationThresholdReached` / `VoteWindowClosed` / `VoteAlreadyFinalized`
- **Unchanged:** open vote, member/co-leader cast, majority math (`floor(eligible/2)+1`), no app-called finalize (cron).

### Open / next (not started unless user asks)

- Device QA of Continue contribution against deployed cancel API.
- Real cancel URL is already `ApiConstants.projectClosureVotingCancel` — do **not** change unless backend moves it.
- No other voting-flow changes unless explicitly requested.
- VFF dot badge: if backend adds a dedicated unread-count endpoint, swap `GET /vff/received-inbox` probe for it in `VffPendingCubit.refresh()`.

### Never commit (local machine only)

| File | Why |
|------|-----|
| `lib/core/constants/api_constants.dart` **baseUrl / invite host** | Local **test** backend vs production Azure |
| `lib/core/constants/stripe_constants.dart` **publishableKey** | Local `pk_test_…` vs production `pk_live_…` |

The **cancel path helper** in `api_constants.dart` **is** committed. Only host/key swaps stay local.

---

## 2. What Vestie is

Collaborative **group savings** Flutter app (Android & iOS). Not a bank.

Users create/join **projects** (vacation, emergency, investment), contribute from a **wallet**, borrow from vacation/emergency pots, pay via **Stripe**, connect via **VFF**, complete **KYC** to withdraw.

| Role | API `viewerRole` | Code |
|------|------------------|------|
| Group Leader | `GroupLeader` | `lib/leader/features/` |
| Co-Leader | `CoLeader` | vacation/emergency only |
| Member | `Member` | `lib/user/features/` |
| Shared | all | `lib/features/`, `lib/core/`, `lib/app/` |

| Category | Borrow | Co-leader | Detail |
|----------|--------|-----------|--------|
| Vacation | Yes | Yes | `/project/detail` |
| Emergency | Yes | Yes | `/project/detail` |
| Investment | No | No | `/project/investment-detail` |

Public join → instant active. Private → pending until leader approves.

**Must-not-break:** auth → agreement → dashboard (Home, Discover, +, Wallet, Profile); wallet/Stripe/SignalR; contribute/borrow/KYC/bank; invite `/join/:inviteCode`; project detail; VFF `/user/vff`; **`AppRoutes` only**.

Full product: [`project_scope.md`](project_scope.md)

---

## 3. Architecture (mandatory)

```text
Screen → Cubit/Bloc → UseCase → Repository → RemoteDataSource → Dio (BaseApiClient)
```

| Layer | May import | Must not |
|-------|------------|----------|
| presentation | domain, `core/` UI | Dio, `ApiConstants` in widgets, raw JSON |
| domain | `core/error`, dartz | Flutter, Dio, models |
| data | domain, `ApiConstants`, Dio | `BuildContext` |

- **Strings:** `AppStrings`. **Colors:** `AppColors`. **Routes:** `AppRoutes` + typed `extra`. **API paths:** `ApiConstants`.
- **API enums:** parse in models; widgets use `entity.isPending`, not `'Pending'`.
- **Layout:** ScreenUtil 390×844 (`.w` `.h` `.r` `.sp`).
- **Feedback:** `AppToast` (not `AppSnackBar`). Load fail → `AppErrorView` + retry. Action fail → toast.
- **Money POST:** reload project detail **before** success UI (`architecture.mdc` §5).
- **State:** Cubit/Bloc for business state; no `setState` for API.

Reference implementation: `lib/user/features/borrow/` and `lib/user/features/contribute/`.

---

## 4. Repo layout

```text
lib/
  main.dart              # production entry
  main_dev.dart          # DevicePreview debug only
  app/                   # GoRouter, AppRoutes, route args
  core/                  # constants, DI, theme, network, common widgets
  features/              # shared (auth, wallet, project_detail, …)
  user/features/         # member (home, discover, contribute, VFF, …)
  leader/features/       # leader (create wizard, moderation, monitor)
```

| Need | File |
|------|------|
| Route constants | `lib/app/router/app_routes.dart` |
| Route tables | `lib/app/router/route_groups/` |
| DI | `lib/core/di/inject_*.dart`, `service_locator.dart` |
| HTTP | `lib/core/network/base_api_client.dart` |

Do **not** bulk-move folders (wave E deferred). Never move `lib/features/wallet/` without explicit approval.

---

## 5. Features → folders → entry

| Feature | Folder | Entry |
|---------|--------|-------|
| Splash / onboarding | `lib/features/splash/`, `onboarding/` | `/` |
| Auth / agreement | `lib/features/auth/` | `/login`, `/register`, `/agreement` |
| Home / Discover | `lib/user/features/home/`, `discover/` | `/dashboard` tabs |
| Create project | `lib/leader/features/create_project/` | + tab |
| Wallet / deposit / withdraw | `lib/features/wallet/` | Wallet tab |
| Contribute | `lib/user/features/contribute/` | `/project/contribute` |
| Borrow | `lib/user/features/borrow/` | `/project/borrow` |
| Project detail (shared) | `lib/features/project_detail/` | `/project/detail` |
| Investment detail | `lib/user/features/project_detail/` | `/project/investment-detail` |
| Leader monitor / join / borrow approve | `lib/leader/features/project_detail/` | `/leader/view-success-votes`, `/join-requests`, … |
| Closure vote cast / outcome | `lib/features/success_vote/` | inline on detail + outcome screen |
| VFF | `lib/user/features/vff/` | `/user/vff` |
| KYC / bank | `lib/features/kyc/`, `bank_accounts/` | `vestie://kyc/*`, `vestie://bank/*` |
| Profile | `lib/features/profile/` | Profile tab |
| Notifications / FCM | `lib/features/notifications/`, `lib/core/services/` | in-app list + taps |

Index: [`FEATURE_MAP.md`](../FEATURE_MAP.md) · traces: [`PROJECT_FLOW_MAP.md`](../PROJECT_FLOW_MAP.md) · roles/flows: [`APP_GUIDE.md`](../APP_GUIDE.md)

---

## 6. Primary flows (short)

```text
Cold start: Splash → invite | dashboard | agreement | login | onboarding
Dashboard:  Home | Discover | Create | Wallet | Profile
Contribute: detail → amount → confirm → POST contribution → reload detail → success
Borrow:     detail → flow → POST → reload detail BEFORE success UI
Vote start: leader ⋯ → intro → voting window days → POST …/open → reload → success
Vote cast:  member/co-leader inline on detail → POST …/vote → reload
Vote watch: Group Leader → View Success Votes → GET /projects/{id} voting
Vote cancel: Group Leader Continue contribution → POST …/cancel → GET detail → pop
Finalize:   backend cron only — app does not POST finalize
```

Screen ↔ API refresh: [`qa/api_screen_sync_matrix.md`](qa/api_screen_sync_matrix.md)  
Member vacation/emergency: [`group_vacation_emergency_member_flow.md`](group_vacation_emergency_member_flow.md)

---

## 7. Key files — Continue contribution / voting

| Layer | Path |
|-------|------|
| Path | `lib/core/constants/api_constants.dart` → `projectClosureVotingCancel` |
| Policy | `lib/features/project_detail/domain/entities/continue_contributions_policy.dart` |
| Gate on entity | `project_detail_closure_extensions.dart` → `showsContinueContributionsAction` |
| DS / model / repo | `closure_voting_remote_data_source.dart`, `closure_voting_response_model.dart`, `closure_voting_repository_impl.dart` |
| Cancel errors | `closure_voting_failure_mapper.dart` → **`mapCancel` only** (open/cast use `map`) |
| Use case / DI | `closure_voting_usecases.dart`, `inject_project.dart`, `service_locator.dart` |
| Cubit / screen | `leader_view_success_votes_cubit.dart`, `leader_view_success_votes_screen.dart` |
| Tests | `continue_contributions_policy_test.dart`, `leader_view_success_votes_cubit_test.dart`, `closure_voting_failure_mapper_test.dart` |
| Backend spec | [`backend_handoff_cancel_closure_vote.md`](backend_handoff_cancel_closure_vote.md) |
| App plan | [`leader_continue_contributions_plan.md`](leader_continue_contributions_plan.md) |

Open/cast still: `VotingWindowCubit` → `open`; members → `POST …/vote`. Do not wire cancel there.

---

## 8. Key files — VFF pending dot badge

| Layer | Path |
|-------|------|
| Bridge | `lib/core/services/notifications/vff_pending_refresh.dart` |
| State | `lib/user/features/vff/presentation/cubit/vff_pending_state.dart` |
| Cubit | `lib/user/features/vff/presentation/cubit/vff_pending_cubit.dart` |
| DI / app-level | `lib/app/main_app.dart` → `BlocProvider<VffPendingCubit>` |
| UI dot | `lib/core/widgets/common/notification_favourite_header_actions.dart` (key `vff_pending_dot`) |
| Hub sync | `lib/user/features/vff/presentation/cubit/user_vff_hub_cubit.dart` → `_syncPendingDot` |
| FCM | `lib/core/services/fcm_push_service.dart` → `VffRequestReceived` → `VffPendingRefresh.notifyPending()` |
| Dashboard refresh | `lib/features/dashboard/presentation/pages/dashboard_screen.dart` |
| Logout reset | `lib/features/profile/presentation/pages/profile_screen.dart` |
| Tests | `test/user/features/vff/cubit/vff_pending_cubit_test.dart`, `test/core/widgets/vff_pending_dot_badge_test.dart` |
| Feature overview | `lib/features/notifications/feature_overview.md` — VFF pending dot section |
| Sync matrix | `DOCS/qa/api_screen_sync_matrix.md` — VFF pending dot row |

---

## 9. Docs map


| Need | Doc |
|------|-----|
| **Resume this work** | **This file** |
| Product scope | [`project_scope.md`](project_scope.md) |
| App guide (roles, voting, money) | [`../APP_GUIDE.md`](../APP_GUIDE.md) |
| Architecture 30-min | [`../ARCHITECTURE_OVERVIEW.md`](../ARCHITECTURE_OVERVIEW.md) |
| Feature index | [`../FEATURE_MAP.md`](../FEATURE_MAP.md) |
| Flow traces | [`../PROJECT_FLOW_MAP.md`](../PROJECT_FLOW_MAP.md) |
| DI | [`../DEPENDENCY_MAP.md`](../DEPENDENCY_MAP.md) |
| Routes / joins | [`architecture_flows.md`](architecture_flows.md) |
| API weeks | [`api_integration_plan.md`](api_integration_plan.md) |
| Screen ↔ API sync | [`qa/api_screen_sync_matrix.md`](qa/api_screen_sync_matrix.md) |
| Outcomes | [`outcome.md`](outcome.md) |
| FCM taps | [`push_notification_routing.md`](push_notification_routing.md) |
| Per-feature | `feature_overview.md` in each feature folder |

When behavior/API/sync changes, update `feature_overview.md` + `api_screen_sync_matrix.md` in the **same** change (`architecture.mdc` §7).

---

## 10. Validation

```bash
flutter analyze
flutter test
```

Analyze **errors** must be zero on changed files. Info lints on untouched files are OK.  
Release APK only after significant changes: `flutter build apk --release`.

Entry: `lib/main.dart`. Do not import `device_preview` from `main_app.dart`.

---

## 11. Suggested first message for a new chat

> Read `DOCS/HANDOFF.md` and all `.cursor/rules/*.mdc`. Follow architecture. Resume Vestie on `final-changes`. Continue contribution and Total Members are shipped. Do not change open/cast voting. Do not commit local `api_constants` / `stripe_constants` test hosts/keys. Next: [describe the task].
