# Common Dialogs Reference

This document maps all reusable dialogs, their source files, and where they are used so updates are easy and safe.

## Core Common Dialog Components

### `AppActionDialog`
- **Actual file:** `lib/core/widgets/common/app_action_dialog.dart`
- **Purpose:** Generic confirmation/result dialog with optional icon, primary/secondary actions, and rich subtitle support (`descriptionWidget`).
- **Used by wrappers:**
  - `lib/features/project_detail/presentation/widgets/borrow_request_decision_dialogs.dart`
  - `lib/features/project_detail/presentation/widgets/join_request_result_dialogs.dart`
  - `lib/features/project_detail/presentation/widgets/member_detail_actions.dart`

### `AppInviteMembersDialog`
- **Actual file:** `lib/core/widgets/common/app_invite_members_dialog.dart`
- **Purpose:** Invite-members dialog (QR, copy link, share via WhatsApp).
- **Direct usage:**
  - `lib/features/project_detail/presentation/pages/project_detail_screen.dart` via `AppInviteMembersDialog.show(context)`

### `AppActionBottomSheet` (Deprecated)
- **Actual file:** `lib/core/widgets/common/app_action_bottom_sheet.dart`
- **Status:** Deprecated in favor of `AppActionDialog`.
- **Recommendation:** Avoid new usage. Use `AppActionDialog` for all new action/confirm/result UI.

## Feature Dialog Wrappers (Project Detail Domain)

These wrappers centralize flow-specific copy and styling while still using the common dialog component.

### Borrow Request Decision Flow
- **Wrapper file:** `lib/features/project_detail/presentation/widgets/borrow_request_decision_dialogs.dart`
- **Public APIs:**
  - `showApproveBorrowRequestFlow(context, request)`
  - `showRejectBorrowRequestFlow(context, request)`
- **Where called:**
  - `lib/features/project_detail/presentation/widgets/project_detail_tab_panels.dart` (leader borrow preview cards)
  - `lib/features/project_detail/presentation/pages/borrow_requests_screen.dart` (leader full list)

### Join Request Result Dialogs
- **Wrapper file:** `lib/features/project_detail/presentation/widgets/join_request_result_dialogs.dart`
- **Public APIs:**
  - `showJoinRequestApprovedDialog(context, memberName: ...)`
  - `showJoinRequestDeclinedDialog(context, memberName: ...)`
- **Where called:**
  - `lib/features/project_detail/presentation/pages/join_requests_screen.dart`

### Member Management Dialog Flows
- **Wrapper file:** `lib/features/project_detail/presentation/widgets/member_detail_actions.dart`
- **Public APIs:**
  - `showRemoveMemberConfirm(context, memberName: ...)`
  - `showMarkDefaultedConfirm(context)`
  - `showMakeCoLeaderFlow(context, memberName: ..., projectName: ...)`
  - `showRemoveCoLeaderFlow(context, memberName: ..., projectName: ...)`
- **Where called:**
  - `lib/features/project_detail/presentation/pages/member_detail_screen.dart` (remove member action)
  - `lib/features/project_detail/presentation/pages/member_penalty_action_screen.dart` (remove member / mark defaulted)
  - `lib/features/project_detail/presentation/widgets/member_detail_sections.dart` (make/remove co-leader button)

## Related Modal/Sheet (Not in Common Dialog System)

### Card Detail Bottom Sheet
- **File:** `lib/features/profile/presentation/widgets/card_detail_sheet.dart`
- **Pattern:** Uses `showModalBottomSheet`.
- **Scope:** Profile/payment card details.
- **Note:** This is a dedicated feature sheet, not part of `AppActionDialog`/`AppInviteMembersDialog`.

## Update Guide

When you want to change dialog UI globally:
- Edit `lib/core/widgets/common/app_action_dialog.dart` for layout, typography, button shape, icon container, spacing.
- Edit `lib/core/widgets/common/app_invite_members_dialog.dart` for invite QR dialog UI.

When you want to change dialog copy/content for one flow:
- Borrow requests: `borrow_request_decision_dialogs.dart`
- Join requests: `join_request_result_dialogs.dart`
- Member actions: `member_detail_actions.dart`

When you want to change where a dialog opens:
- Search by wrapper function name first (for example `showApproveBorrowRequestFlow`, `showRemoveMemberConfirm`).

