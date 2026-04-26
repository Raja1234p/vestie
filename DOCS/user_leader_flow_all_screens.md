# Vestie User vs Leader Flow (All Screens)

This document explains every current route/screen with:

- what **User (member)** sees
- what **Leader** sees
- where each flow navigates next

Use this as the master UI-flow reference before API integration.

---

## 1) Common Entry + Auth Flow

1. `/` -> `SplashScreen`
2. `/onboarding` -> `OnboardingScreen`
3. Auth:
   - `/login` -> `LoginScreen`
   - `/register` -> `RegisterScreen`
   - `/verify` -> `VerifyScreen` (`extra: email`)
   - `/forgot-password` -> `ForgotPasswordScreen`
   - `/reset-password` -> `ResetPasswordScreen` (`extra: email`)
   - `/agreement` -> `AgreementScreen`
4. `/dashboard` -> `DashboardScreen`

### What user sees vs leader sees

- **User:** Same onboarding/auth screens as leader.
- **Leader:** Same onboarding/auth screens as user.
- Role-specific UI starts after entering project-related screens.

---

## 2) Dashboard Shell (Common)

Route: `/dashboard` (`DashboardScreen`)

Tabs:
1. Home (`HomeScreen`)
2. Discover (`DiscoverScreen`)
3. Add (opens create project wizard)
4. Wallet (`WalletScreen`)
5. Profile (`ProfileScreen`)

### User view

- Uses Home joined projects + user-specific project actions.
- Can open wallet and profile operations.

### Leader view

- Uses Home my-projects area + leader management actions.
- Add tab is primary entry for creating projects.

---

## 3) Home + Discover Card Open Flow

Card open entry is centralized in `openProjectFromCard(...)`.

### User view (member)

- If special member test flow exists on card:
  - `/user/status-flow` (`UserStatusFlowArgs`) or
  - `/user/success-vote` (`UserSuccessVoteArgs`)
- Otherwise:
  - `/project/detail` or `/project/investment-detail`
  - `extra: ProjectDetailRouteArgs`

### Leader view

- Opens normal detail only:
  - `/project/detail` or `/project/investment-detail`
  - `extra: ProjectDetailRouteArgs`

---

## 4) Project Detail Screen Family

Routes:
- `/project/detail` -> `ProjectDetailScreen`
- `/project/investment-detail` -> `InvestmentProjectDetailScreen`

### User view

Shows:
- project header (no leader action menu)
- announcement + project info
- Contribute and Borrow buttons
- tabs/panels for member-related lists
- member details, borrow request list in user mode

Can navigate to:
- `/project/contribute` (`ProjectWalletFlowArgs`)
- `/project/borrow` (`ProjectWalletFlowArgs`)
- `/project/member-detail` (`MemberDetailRouteArgs`)
- `/project/borrow-requests` (`BorrowRequestsRouteArgs(isLeaderMode: false)`)

### Leader view

Shows:
- same core project content
- **leader action menu** in header
- leader-specific tab content (manage members, leader borrow requests)

Can navigate to:
- `/project/join-requests`
- `/project/create-announcement`
- `/create-project/details` (`extra: true`, edit mode)
- `/project/mark-successful` (`MarkSuccessfulRouteArgs`)
- `/project/cancel` (`CancelProjectRouteArgs`)
- `/project/borrow-requests` (`BorrowRequestsRouteArgs(isLeaderMode: true)`)
- `/project/member-detail` (`MemberDetailRouteArgs(isLeaderView: true)`)

---

## 5) Contribute Flow

Route: `/project/contribute` -> `ContributeFlowScreen`

Steps:
1. Amount (system keyboard stacked field)
2. Confirm (payment method + breakdown + acceptance switch)
3. Success (`AppSuccessScreen`)

### User view

- Main actor of this flow.
- Submits contribution to project wallet.

### Leader view

- If leader taps contribute, same UI and behavior as user.

---

## 6) Borrow Flow

Route: `/project/borrow` -> `BorrowFlowScreen`

Steps:
1. Amount + note (system keyboard stacked field)
2. Terms + acceptance switch
3. Success (`AppSuccessScreen`)

### User view

- Primary member borrow request flow.
- Sends request for leader/group decision.

### Leader view

- If leader uses borrow button, same UI behavior.

---

## 7) Borrow Requests Listing

Route: `/project/borrow-requests`
Args: `BorrowRequestsRouteArgs`

### User view

- Sees own/member-side borrow request list context.
- `isLeaderMode: false` behavior.

### Leader view

- Sees moderation-style borrow request list.
- `isLeaderMode: true` behavior.

---

## 8) Member Detail + Penalty

Routes:
- `/project/member-detail` (`MemberDetailRouteArgs`)
- `/project/member-penalty-action` (`MemberEntity`)

### User view

- Member detail screen opens in non-leader mode (`isLeaderView: false`).
- No leader-only punitive actions.

### Leader view

- Member detail opens with leader mode (`isLeaderView: true`).
- Can proceed to penalty action flow where applicable.

---

## 9) Leader Administration Flows

## A) Join requests

- Route: `/project/join-requests`
- **User view:** Not available as a primary route from user UI.
- **Leader view:** Approve/reject incoming join requests.

## B) Announcement creation

- Route: `/project/create-announcement`
- **User view:** Not available as a primary route from user UI.
- **Leader view:** Create/update project announcement.

## C) Mark project successful

- Route: `/project/mark-successful` (`MarkSuccessfulRouteArgs`)
- **User view:** Consumes outcome in user status/vote screens.
- **Leader view:** Initiates successful-completion vote workflow.

## D) Cancel project

- Routes:
  - `/project/cancel` (`CancelProjectRouteArgs`)
  - `/project/cancelled` (`ProjectCancelledRouteArgs`)
- **User view:** Sees cancelled state/outcome.
- **Leader view:** Executes cancellation path.

---

## 10) User Status/Vote Result Screens (Member-facing)

Routes:
- `/user/status-flow` (`UserStatusFlowArgs`)
- `/user/success-vote` (`UserSuccessVoteArgs`)

### User view

- Receives join approved/rejected and mark-vote outcomes.
- Can cast vote in `user-success-vote` flow where enabled.

### Leader view

- Not a primary leader-operational screen; leader triggers events that lead users here.

---

## 11) Create Project Wizard (Leader-centric)

Routes:
1. `/create-project/amount`
2. `/create-project/details`
3. `/create-project/borrowing`
4. `/create-project/review`
5. `/create-project/success`

Edit mode:
- `/create-project/details` with `extra: true`
- `/create-project/borrowing` with `extra: true`

### User view

- Generally not primary; Add tab can open wizard but business intent is leader/project creator.

### Leader view

- Main project creation and editing pipeline.

---

## 12) Wallet Transaction Flow

Routes:
1. `/wallet/transaction-amount`
2. `/wallet/select-payment-method`
3. `/wallet/transaction-confirmation`
4. `/wallet/transaction-success`

### User view

- Deposit/withdraw own wallet balance.

### Leader view

- Same wallet UX; not role-restricted in current UI.

---

## 13) Profile Flow

Routes:
- `/profile/edit`
- `/profile/payment-methods`
- `/profile/payment-methods/add-card`
- `/profile/transaction-history`
- `/profile/key-guidelines`

### User view

- Full profile management and payment methods.

### Leader view

- Same profile/payment features.

---

## 14) Notifications

Route: `/notifications`

### User view

- Sees notification list and states.

### Leader view

- Same notification screen (role-specific payload can be differentiated later by API).

---

## 15) Supported Project Types + UI Location

Current supported project categories in runtime project entities:

- `vacations`
- `emergency`
- `investment`

Create wizard category options:

- `Vacation`
- `Emergency`
- `Investment`
- `Other` (present in create form enum; currently no dedicated detail-route variant)

### Where each project type UI appears

- **Home/Discover card chips**
  - Category chip rendering: `project_card_chip_widgets.dart`
  - Used in project cards for both user and leader views.

- **Project detail info chips**
  - Category chips: `project_info_card_chips.dart`
  - Visible inside both detail screens.

- **Completed-state category copy**
  - Copy branching: `completed_project_notice_copy.dart`
  - Investment text differs from vacations/emergency.

- **Create Project category selector**
  - Selector/dropdown UI: `project_details_widgets.dart`
  - Category state enum: `create_project_form.dart` (`NewProjectCategory`)

### Route + screen by category

- **Investment**
  - Route: `/project/investment-detail`
  - Screen: `InvestmentProjectDetailScreen`

- **Vacations**
  - Route: `/project/detail`
  - Screen: `ProjectDetailScreen`

- **Emergency**
  - Route: `/project/detail`
  - Screen: `ProjectDetailScreen`

### User view vs leader view by category

- Role behavior is controlled by `project.isLeader`, not by category:
  - Leader gets leader menu + moderation/management actions.
  - User gets member actions + member status/vote flows.
- Category controls:
  - which detail route opens (`investment-detail` vs `project/detail`)
  - category chips/icons/labels
  - some completed-state copy variants.

### Category-wise flow attachment (User vs Leader)

#### 1) Investment project

- **User path**
  - Home/Discover card -> `/project/investment-detail`
  - Can open contribute: `/project/contribute`
  - Can open borrow: `/project/borrow`
  - Can open member detail / borrow requests in user mode
- **Leader path**
  - Home card (My Projects) -> `/project/investment-detail`
  - Sees leader menu: join requests, announcement, edit, mark successful, cancel
  - Can open borrow requests in leader mode and member management flows
- **Primary UI files**
  - `investment_project_detail_screen.dart`
  - `project_card_chip_widgets.dart`
  - `project_info_card_chips.dart`
  - `completed_project_notice_copy.dart` (investment-specific completed copy)

#### 2) Emergency project

- **User path**
  - Home/Discover card -> `/project/detail`
  - Can contribute/borrow/member-detail/borrow-requests (user mode)
- **Leader path**
  - Home card (My Projects) -> `/project/detail`
  - Same leader controls from header menu and tabs
- **Primary UI files**
  - `project_detail_screen.dart`
  - `project_card_chip_widgets.dart`
  - `project_info_card_chips.dart`
  - `completed_project_notice_copy.dart` (shared with vacations)

#### 3) Vacation project

- **User path**
  - Home/Discover card -> `/project/detail`
  - Can contribute/borrow/member-detail/borrow-requests (user mode)
- **Leader path**
  - Home card (My Projects) -> `/project/detail`
  - Same leader controls from header menu and tabs
- **Primary UI files**
  - `project_detail_screen.dart`
  - `project_card_chip_widgets.dart`
  - `project_info_card_chips.dart`
  - `completed_project_notice_copy.dart` (shared with emergency)

#### 4) Other category (create flow only today)

- **Current status**
  - Available in create wizard category picker (`NewProjectCategory.other`)
  - Runtime project entity currently supports only `vacations|emergency|investment`
- **Effect on flow**
  - No dedicated detail route/type mapping yet
  - To fully support it end-to-end, add:
    - domain enum mapping (`ProjectCategory`)
    - card/detail chip mapping
    - route decision mapping in `open_project_from_card.dart`
    - completed copy branch if needed

---

## 16) Route Args Contract (must stay aligned)

- `/verify` -> `String`
- `/reset-password` -> `String`
- `/project/detail`, `/project/investment-detail` -> `ProjectDetailRouteArgs`
- `/project/contribute`, `/project/borrow` -> `ProjectWalletFlowArgs`
- `/project/member-detail` -> `MemberDetailRouteArgs`
- `/project/member-penalty-action` -> `MemberEntity`
- `/project/borrow-requests` -> `BorrowRequestsRouteArgs`
- `/project/mark-successful` -> `MarkSuccessfulRouteArgs`
- `/project/cancel` -> `CancelProjectRouteArgs`
- `/project/cancelled` -> `ProjectCancelledRouteArgs`
- `/user/status-flow` -> `UserStatusFlowArgs`
- `/user/success-vote` -> `UserSuccessVoteArgs`

If `extra` type is wrong, router falls back to invalid route screen.

---

## 17) Full Route Inventory (All current screens)

- `/`
- `/onboarding`
- `/login`
- `/register`
- `/verify`
- `/forgot-password`
- `/reset-password`
- `/agreement`
- `/dashboard`
- `/notifications`
- `/create-project/amount`
- `/create-project/details`
- `/create-project/borrowing`
- `/create-project/review`
- `/create-project/success`
- `/profile/edit`
- `/profile/payment-methods`
- `/profile/payment-methods/add-card`
- `/profile/transaction-history`
- `/profile/key-guidelines`
- `/wallet/transaction-amount`
- `/wallet/select-payment-method`
- `/wallet/transaction-confirmation`
- `/wallet/transaction-success`
- `/project/detail`
- `/project/investment-detail`
- `/project/contribute`
- `/project/borrow`
- `/project/member-detail`
- `/project/member-penalty-action`
- `/project/create-announcement`
- `/project/join-requests`
- `/project/borrow-requests`
- `/project/mark-successful`
- `/project/cancel`
- `/project/cancelled`
- `/user/status-flow`
- `/user/success-vote`

---

## 18) Category QA Checklist

| Category | User Route | Leader Route | Detail Screen | Fully Supported |
|---|---|---|---|---|
| Investment | `/project/investment-detail` | `/project/investment-detail` | `InvestmentProjectDetailScreen` | Yes |
| Emergency | `/project/detail` | `/project/detail` | `ProjectDetailScreen` | Yes |
| Vacation | `/project/detail` | `/project/detail` | `ProjectDetailScreen` | Yes |
| Other (create only) | N/A (not mapped in runtime entity) | N/A (not mapped in runtime entity) | N/A | No |


