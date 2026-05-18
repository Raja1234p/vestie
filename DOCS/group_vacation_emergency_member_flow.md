# Group Vacation & Emergency — Member Flow Reference

This document describes how **member-facing** Vacation and Emergency flows work in the Vestie app **today** (UI + local/mock logic). Use it when backend APIs arrive to wire the same screens without changing product behavior.

**Scope:** `ProjectCategory.vacations` and `ProjectCategory.emergency` only. Investment projects use different detail UI (no borrow, different overflow rules).

### Recently implemented (member UI)

| Item | Status |
|------|--------|
| **Vote outcome screens** | Approved / Not approved (`MemberVoteOutcomeScreen`, Figma styling) |
| **Dev previews on member detail** | Success vote (inline), vote approved, vote rejected |
| **`AppSuccessScreen` background** | White + `empty_state_background.png` at top for all success screens (contribute, borrow, vote outcome, etc.) — no full-screen auth gradient |
| **Detail back navigation** | `popProjectDetailNavigation` uses `canPop()` with dashboard fallback when stack is empty |

**Last aligned with code:** `lib/user/features/create_project_member_fund/`, `lib/features/project_detail/`, `lib/user/features/contribute/`, `lib/user/features/borrow/`, `lib/user/features/project_detail/` (success vote + vote outcome), `lib/core/widgets/common/app_success_screen.dart`.

---

## 1. Two separate member experiences

| Track | Purpose | Data source today |
|--------|---------|-------------------|
| **A. Member fund storyboard** | Create / preview a vacation or emergency fund (design walkthrough) | `CreateProjectFundDraft` passed via `GoRouter` `extra` — **no API** |
| **B. Joined project detail** | Act on a real project the member already joined | `GET /projects/{id}` → `ProjectDetailEntity` (partial API); wallet flows **UI-only** |

These tracks are **not** connected: finishing storyboard A does not create a server project. Real projects open via home/discover → project detail (track B).

---

## 2. Category detection

```dart
// lib/features/project_detail/domain/entities/project_detail_entity.dart
bool get isVacationOrEmergency =>
    category == ProjectCategory.vacations ||
    category == ProjectCategory.emergency;
```

**Member-only differences vs investment:**

| Rule | Vacation / Emergency | Investment |
|------|----------------------|------------|
| Borrow CTA on detail | Yes, if `borrowingEnabled` | Hidden (`showsBorrowAction` false) |
| Overflow menu includes **My Borrows** | Yes (`memberProjectMenuIncludesMyBorrows`) | No |
| Success vote UI | Yes (leader starts vote; member votes) | N/A (different lifecycle) |
| Contribute + Borrow from detail | Both when enabled | Contribute only |

---

## 3. Track A — Member fund storyboard (Vacation / Emergency setup)

### 3.1 Entry

- **Widget:** `showCreateProjectMemberWalkthroughSheet`  
  `lib/user/features/create_project_member_fund/presentation/widgets/create_project_member_walkthrough_sheet.dart`
- **Routes:** user picks Vacation or Emergency → setup screen.
- **Note:** Walkthrough sheet exists; ensure product entry (e.g. dev link / leader create flow) calls `showCreateProjectMemberWalkthroughSheet(context)` — string `AppStrings.createProjectMemberWalkthroughLink` is defined but may not be wired on all builds.

### 3.2 Route map

| Step | Route constant | Screen | `extra` type |
|------|----------------|--------|--------------|
| 1a | `AppRoutes.createProjectVacationSetup` | `CreateProjectVacationSetupScreen` | — |
| 1b | `AppRoutes.createProjectEmergencySetup` | `CreateProjectEmergencySetupScreen` | — |
| 2 | `AppRoutes.createProjectFundSummary` | `CreateProjectSummaryScreen` | `CreateProjectFundDraft` |
| 3 | `AppRoutes.createProjectFundDetail` | `CreateProjectFundDetailScreen` | `CreateProjectFundDraft` |
| 4 | `AppRoutes.createProjectFundContributionProgress` | `CreateProjectContributionProgressScreen` | `CreateProjectFundDraft` |
| 5 | `AppRoutes.createProjectFundStatus` | `CreateProjectStatusScreen` | `CreateProjectStatusScreenArgs` |

Router: `lib/app/router/route_groups/create_project_member_flow_routes.dart`  
Comment in code: *"Vacation & Emergency member walkthrough routes (pure UI — no APIs)."*

### 3.3 Shared setup screen

Both variants use `CreateProjectFundMemberSetupScreen` with `CreateProjectFundKind`:

- **vacation** — title `AppStrings.createProjectVacationFundTitle`, default goal mock `10750`, hero `vacation_hero.png`
- **emergency** — title `AppStrings.createProjectEmergencyFundTitle`, default goal mock `1450`, hero `emergency_hero.png`

**Fields collected (local validation only):**

| Field | Validation |
|-------|------------|
| Project name | Required |
| Goal (USD) | Required, numeric \> 0 |
| Start date | Date picker |
| End date | Must be ≥ start + 1 day |
| Description | Optional text |

**On Continue:** builds `CreateProjectFundDraft` → `context.push(createProjectFundSummary, extra: draft)`.

**Future API (suggested):** `POST /projects` (or member-draft endpoint) with `category`, `name`, `goalAmount`, `startDate`, `endDate`, `description` — then navigate to summary/detail with returned `projectId` instead of draft-only.

### 3.4 Summary → Detail → Contribution progress → Status

- **Summary:** read-only card (goal, dates, about); **Create Project** → detail (still mock).
- **Detail:** mock leader card, member avatars, **Contribute** → contribution progress (not real `contributeFlow`).
- **Contribution progress:** circular % from `draft.mockPercentTowardGoal` (35% vacation / 42% emergency); mock transaction list.
  - Dev buttons: **Simulate payment success/failure** → status screen.
  - **Done** pops route (does not complete a real payment).
- **Status:** `AppSuccessScreen` on success (empty-state background); failure uses white + `AppAssets.failureIcon` (or status screen pattern).

**Future API:** replace mocks with `GET /projects/{id}/contributions/summary`, payment intent confirm, etc.; keep same route sequence where possible.

---

## 4. Track B — Joined project detail (live member)

### 4.1 Opening a project

- **Normal:** `openProjectFromCard` / `openProjectDetailById` → `AppRoutes.projectDetail` or investment variant.
- **Mock shortcuts** on home/discover cards via `Project.userFlow` (`UserFlowOnOpen`):
  - `showJoinApproved` / `showJoinRejected` → `userStatusFlow`
  - `showSuccessVote` → `userSuccessVote` with `UserSuccessVoteArgs`
  - `showMarkVoteApprovedResult` / `showMarkVoteNotApprovedResult` → status flows

Files: `lib/features/project_detail/presentation/navigation/open_project_from_card.dart`, `lib/user/features/home/domain/entities/user_flow_on_open.dart`.

### 4.2 Member layout shell

**Widget:** `ProjectDetailMemberLayout`  
`lib/features/project_detail/presentation/widgets/project_detail_member_layout.dart`

- **Default body:** `ProjectDetailMemberScrollContent` (announcement, info card, wallet CTAs, tabs).
- **Success vote preview (dev):** `AppStrings.btnPreviewSuccessVote` toggles embedded `MemberSuccessVoteContent` with `MemberSuccessVoteUiData.fromProject(project)` — only when `isVacationOrEmergency`.
- **Vote outcome preview (dev):** `AppStrings.btnPreviewVoteOutcomeApproved` / `btnPreviewVoteOutcomeRejected` → `ProjectDetailNavigationHelpers.openMemberVoteOutcomePreview` → route `AppRoutes.userVoteOutcome` with mock `MemberVoteOutcomeUiData.preview`.
- **Production:** when API signals active success vote, replace preview flags with server state; navigate to vote outcome when vote closes (majority approved / not approved).

### 4.3 Detail body composition

`ProjectDetailMemberScrollContent`:

1. `AnnouncementCard` (read-only for members)
2. `ProjectInfoCard` (goal, progress, chips — from entity)
3. `ProjectDetailWalletActions`
4. `ProjectDetailTabSection` (members, etc.)

### 4.4 Wallet actions (Contribute / Borrow)

**Widget:** `ProjectDetailWalletActions`  
**Args:** `ProjectWalletFlowArgs` from `ProjectDetailNavigationHelpers.walletArgs(project)`:

| Field | Source |
|-------|--------|
| `projectId` | `project.id` |
| `projectName` | `project.name` |
| `walletBalance` | Default `2400` unless passed from API later |
| `borrowLimit` | `project.borrowLimitAmount` or default `250` |
| `borrowDueByLabel` | `repaymentWindowDays` → `"In N days"` or default label |
| `membershipId` | `project.membershipId` |

**Routes:**

- Contribute → `AppRoutes.contributeFlow` + `extra: walletArgs`
- Borrow → `AppRoutes.borrowFlow` + `extra: walletArgs` (only if `showsBorrowAction`)

---

## 5. Contribute flow (from vacation/emergency detail)

**Screen:** `ContributeFlowScreen`  
**State:** `ContributeBloc` — **new instance per navigation** via `ServiceLocator.createContributeBloc()` (do not use a singleton; `BlocProvider` closes on pop).

### 5.1 Steps

| Step | UI | Current behavior |
|------|-----|------------------|
| `amount` | Amount + `AppWalletBalanceChip` | UI-only; no config/preview API |
| `confirm` | Payment method card + breakdown + non-refundable checkbox | Fee: 3% local (`vestieFee`); submit UI-only ~400ms delay |
| `success` | `AppSuccessScreen` (empty-state top background) | **Back to Project** pops flow |

### 5.2 Confirm screen rules (keep when wiring API)

- Payment row: label `Payment from:` + white `AppWalletBalanceChip` (chevron, `arrow-down-01.svg`, min width `140.w`).
- Payment card padding: `20.h` top/bottom, `16.w` sides.
- Breakdown card: same styling as borrow terms (`searchBarBg`, `neutral400` border).
- Divider: **only** before Total Deduction, color `#D9D9D9` (`AppColors.neutral400`) — **no** divider between contribution amount and Vestie fee.
- Checkbox copy: `AppStrings.contributeNonRefundable` (plain text, no amount emphasis).
- Footer: `SafeArea` `16.w` / `24.h` — same as borrow terms.

### 5.3 API integration checklist (contribute)

| Event | Use case (already in DI) | Notes |
|-------|--------------------------|-------|
| Route open | `FetchContributionConfigUseCase` | Wallets, limits → `selectedWalletId`, enable Confirm |
| Go to confirm | `PreviewContributionUseCase` | Populate breakdown; handle errors on `previewFailure` |
| Confirm | `ConfirmContributionUseCase` | On success → `ContributeStep.success` |
| Errors | `BlocListener` on `submitFailure` / `previewFailure` | Already shows `AppSnackBar` |

Restore implementations in `lib/user/features/contributions/presentation/bloc/contribute_bloc.dart` (marked UI-only today).

---

## 6. Borrow flow (from vacation/emergency detail)

**Screen:** `BorrowFlowScreen`  
**State:** `BorrowCubit` — **created per route** `BorrowCubit(extra)` (safe pattern).

### 6.1 Steps

| Step | UI | Current behavior |
|------|-----|------------------|
| `amount` | `AppStackedCurrencyField`, borrow limit chip, optional note | Local digits; over-limit blocks Confirm |
| `confirm` | Borrow terms cards + checkbox (`Text.rich` with amount + due date) | UI-only submit ~400ms |
| `success` | `AppSuccessScreen` (empty-state top background) + rich subtitle | **Back to Project** |

### 6.2 Terms UI reference

- Section labels: `16.sp` w700 `grey1100`
- Cards: `#F8F7FA`, border `#D9D9D9`, `AppPurpleDashedLine` between rows
- Rows: label `14.sp` `neutral700`, value `16.sp` w600 `neutral1200`
- Submit: `AppStrings.btnSubmitBorrowRequest`

### 6.3 API integration checklist (borrow)

| Event | Use case | Notes |
|-------|----------|-------|
| Submit | `CreateBorrowRequestUseCase` | Replace `BorrowCubit._submitBorrowRequest` delay |
| Detail list | Map `borrowRequests` on `ProjectDetailEntity` | Today often empty in response model |
| My Borrows menu | `MyBorrowRequestArgsBuilder.fromProject` | Preview/mock args until list API wired |

---

## 7. Member overflow menu (vacation / emergency)

**Widget:** `MemberProjectActionMenu` with `includeMyBorrows: project.memberProjectMenuIncludesMyBorrows`

| Action | Navigation |
|--------|------------|
| Project funds history | `projectFundsHistory` + `ProjectFundsHistoryLedgerBuilder.fromProject` |
| My Borrows | `myBorrowRequest` (vacation/emergency only) |
| Invite members | `AppInviteMembersDialog` — **UI-only** sample link (`TODO` restore `createInviteUseCase`) |
| Leave project | `leaveProjectWarning` |

Handler: `ProjectDetailNavigationHelpers.handleMemberAction`.

---

## 8. Success vote (member)

### 8.1 Full-screen route

- **Route:** `AppRoutes.userSuccessVote`
- **Args:** `UserSuccessVoteArgs` (`projectId`, `projectName`, `goalAmount`, `memberCount`, `totalRaised`, `deadlineLabel`, `daysRemaining`)
- **Screen:** `UserSuccessVoteScreen` → `MemberSuccessVoteContent`

### 8.2 Embeddable UI (detail preview)

- **Model:** `MemberSuccessVoteUiData` — `fromProject`, `fromArgs`
- **Choice state:** `MemberSuccessVoteChoice` pending → agreed / disagreed (local only)
- **Widgets:** `member_success_vote_scroll_body.dart`, `member_success_vote_actions.dart`, `member_success_vote_body.dart`

### 8.3 API integration checklist (success vote)

| Concern | Suggested mapping |
|---------|-------------------|
| Show vote UI | Project flag e.g. `successVoteStatus == active` from `GET /projects/{id}` |
| Stats | `goalAmount`, `currentAmount`, member count, deadline from API |
| Cast vote | `SubmitVoteUseCase` / voting repository (already in DI for other flows) |
| Member tallies | Replace mock counts in `MemberSuccessVoteMemberVotes` |

Remove dev preview buttons (`btnPreviewSuccessVote`, vote outcome previews) when driven by API.

### 8.4 Member vote outcome (majority result — Figma)

Shown after the success vote closes. **Not** the same as casting a vote (`MemberSuccessVoteContent`) or immediate feedback (`UserStatusFlowScreen` after Yes/No).

| Variant | Route | Screen |
|---------|-------|--------|
| Approved | `AppRoutes.userVoteOutcome` | `MemberVoteOutcomeScreen` |
| Not approved | same | same (`MemberVoteOutcomeUiData.isApproved`) |

**Args:** `MemberVoteOutcomeRouteArgs` → `MemberVoteOutcomeUiData` (`isApproved`, `amountUsd`, `agreedCount`, `disagreedCount`, `totalMemberCount`). Preview uses Figma-style mocks (e.g. 5/7, 71%/29%, amount from `project.currentAmount` when available).

**Layout:** `AppSuccessScreen` with:
- Hero: `AppAssets.projectCreatedImage` (approved) or `AppAssets.failureIcon` (rejected)
- `illustrationTopSpacing: 40.h` (top gap before hero)
- Title / subtitle: `AppStrings.projectVoteApprovedTitle` / `projectVoteNotApprovedTitle`, etc.
- **Amount card:** `MemberVoteOutcomeAmountCard` — caption `projectVoteFundsReleasedToGlWallet` or `projectVoteContributionsRefunding`; bg `#F0FBF7` (`AppColors.green100`), border `#BAEDDA` (`AppColors.green300`); caption `#737373` (`neutral700`) 14sp w600; amount `green900` 32sp w700
- **Vote summary:** `MemberVoteOutcomeVoteSummary` — rows `MemberVoteOutcomeVoteSummary` / `_VoteRow`; card bg `#F8F7FA` (`grey100`), border `#BFBFBF` (`neutral500`); “N of M members” `neutral700` 14sp w500; Agreed/Disagreed labels green/red; majority row listed first per variant
- Footer: `AppStrings.btnBackToHome` → `context.go(AppRoutes.dashboard)`

**Widgets / model:**

```
lib/user/features/project_detail/presentation/
  pages/member_vote_outcome_screen.dart
  models/member_vote_outcome_ui_data.dart
  widgets/member_vote_outcome/
    member_vote_outcome_amount_card.dart
    member_vote_outcome_vote_summary.dart
```

### 8.5 API integration checklist (vote outcome)

| Concern | Suggested mapping |
|---------|-------------------|
| Navigate here | After vote deadline + tally from `GET /projects/{id}` or push notification |
| Amount / refund copy | Server fields for released total vs refund total |
| Vote breakdown | `agreedCount`, `disagreedCount`, `totalMemberCount`, percents from API |
| Remove previews | Drop `openMemberVoteOutcomePreview` entry points when production routing exists |

---

## 9. Shared UI components (reuse when extending)

| Component | Path |
|-----------|------|
| Member fund header / fields / primary button | `lib/core/widgets/member_project_flow/` |
| Wallet balance chip | `lib/core/widgets/common/app_wallet_balance_chip.dart` |
| Success screen | `lib/core/widgets/common/app_success_screen.dart` — **all** success flows: white base + top `AppAssets.emptyStateBackground` only (no `auth_gradient_bg` full bleed). Optional `illustrationAsset`, `illustrationTopSpacing`. |
| Invite bottom sheet | `lib/core/widgets/common/app_invite_members_dialog.dart` |
| Post-auth gradient background | `lib/core/widgets/common/post_auth_gradient_background.dart` — detail screens still use `appGradient` on white; **not** used on `AppSuccessScreen` |

---

## 10. File index (quick navigation)

```
lib/user/features/create_project_member_fund/
  presentation/pages/create_project_vacation_setup_screen.dart
  presentation/pages/create_project_emergency_setup_screen.dart
  presentation/pages/create_project_fund_member_setup_screen.dart
  presentation/pages/create_project_summary_screen.dart
  presentation/pages/create_project_fund_detail_screen.dart
  presentation/pages/create_project_contribution_progress_screen.dart
  presentation/pages/create_project_status_screen.dart
  presentation/models/create_project_fund_draft.dart

lib/features/project_detail/
  presentation/widgets/project_detail_member_layout.dart
  presentation/widgets/project_detail_member_scroll_content.dart
  presentation/widgets/project_detail_wallet_actions.dart
  presentation/navigation/project_detail_navigation_helpers.dart

lib/user/features/contribute/presentation/pages/contribute_flow_screen.dart
lib/user/features/contributions/presentation/bloc/contribute_bloc.dart

lib/user/features/borrow/presentation/pages/borrow_flow_screen.dart
lib/user/features/borrow/presentation/cubit/borrow_cubit.dart

lib/user/features/project_detail/presentation/
  pages/user_success_vote_screen.dart
  pages/member_vote_outcome_screen.dart
  widgets/member_success_vote_*.dart
  widgets/member_vote_outcome/
  models/member_success_vote_ui_data.dart
  models/member_vote_outcome_ui_data.dart

lib/app/router/route_groups/create_project_member_flow_routes.dart
lib/app/router/route_groups/project_routes.dart
lib/app/router/route_args/project_wallet_flow_args.dart
```

---

## 11. Integration principles (when APIs land)

1. **Do not change route names** unless product requires it — map API results into existing `extra` args and bloc/cubit state.
2. **Keep per-flow bloc lifecycle:** `createContributeBloc()` per push; `BorrowCubit` per push — avoids `Cannot add new events after calling close`.
3. **Preserve vacation vs emergency** via `ProjectCategory` and `CreateProjectFundKind`; same screens, different copy/hero/mock defaults.
4. **Align confirm/breakdown UI** with borrow terms (documented above) when preview API returns real fees.
5. **Replace mock `UserFlowOnOpen`** on home cards with fields from project list API (`viewerState`, `pendingSuccessVote`, etc.).
6. **Storyboard track A:** either deprecate in favor of leader-led create, or connect setup submit to real `POST /projects` and then deep-link to track B detail.

---

## 12. Current UI-only / mock summary

| Area | Status |
|------|--------|
| Member fund storyboard (A) | Fully local draft |
| Contribute preview/confirm/submit | UI delay; use cases stubbed in bloc |
| Borrow submit | UI delay |
| Invite members | Sample link string |
| Success vote on detail | Preview toggle + local vote choice |
| Vote outcome (approved / rejected) | `userVoteOutcome` route; dev preview from member detail |
| `AppSuccessScreen` background | White + `empty_state_background.png` at top (Home/Discover style) |
| Wallet balance on chip | From `ProjectWalletFlowArgs` defaults unless API adds wallet to detail |
| `borrowRequests` on detail | Often empty in model — My Borrows uses builder preview |

When integrating, search codebase for `TODO(api)` and `UI-only` in these feature folders.
