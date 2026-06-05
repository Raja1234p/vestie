# Session handoff — 2026-05-24

Resume point for Vestie Flutter work (VFF API audit + project invite flow).

**Status:** Project invite / join success flow — **COMPLETE** (2026-05-24).

---

## 1. VFF API integration audit (not fully implemented)

**Done (data layer):** All 14 VFF endpoints in `ApiConstants` + `VffRemoteDataSourceImpl` + `VffRepository` + use cases + DI.

**Wired in UI:** Hub My VFFs, received inbox, profile (connected/public), member detail send/remove VFF, invite members sheet.

**Still TODO (from audit):**
- Wire **Sent inbox** (`GET /users/me/inbox/sent`) — use case exists, no cubit/UI (`UserVffSentRow` + mapper ready).
- **Refresh hub My VFFs** after accept/decline on Requests tab.
- Show **`projectType`** on incoming VFF request cards (“via {name} — {type}”).
- Remove dead code: `user_vff_profile_lookup.dart` (unused mocks).
- Home heart still passes `UserVffHubRouteArgs(demoFilled())` in `notification_favourite_header_actions.dart` — harmless while `previewDemoCards = false`.
- API doc: `tool/api_vff_doc.txt`

---

## 2. Project invitation screen (invite link flow) — COMPLETE

**Entry:** `vestie.app/join/{inviteCode}` → `ProjectInvitationScreen` + `ProjectInvitationCubit`.

### UI polish (this session)
- **Maybe Later spacing:** Only `SizedBox(height: 16.h)` above link; `InkWell` padding `EdgeInsets.only(bottom: 12.h)` — `project_invitation_footer.dart`.
- **Project Type pill:** bg `purple100` (#F5F0FE), border `purple300` (#DDD0FC), label `guidelineTitle` (#140930) w500, icon `primary` — `project_invitation_stats_row.dart`.

### Join API
- `POST /api/v1/projects/join` with invite code.
- Response `status: "pending"` → `JoinProjectResultEntity.isPendingMembership`.

### Success navigation (fixed + unified)
**Problem was:** pending went to dashboard + snackbar.

**Now:**
- **Public / immediate:** `ProjectInvitationJoinOpenDetail` → `openProjectJoinedSuccess(..., fromInviteLink: true)` → `ProjectJoinedSuccessScreen` — title “Project Joined”, “Open Project” → project detail.
- **Private / pending:** `ProjectInvitationJoinShowRequestSubmitted` → `openProjectJoinRequestSentSuccess(..., fromInviteLink: true)` → same `ProjectJoinedSuccessScreen` / `AppSuccessScreen` — title “Request Sent”, static subtitle, **Done** → dashboard.

**Shared screen:** `lib/features/projects/presentation/pages/project_joined_success_screen.dart`
- Uses default `AppSuccessScreen` hero (same layout as public; no separate image path in screen file currently).
- `ProjectJoinedSuccessRouteArgs`: `kind` (`immediate` | `requestPending`), `fromInviteLink` (clears `PendingProjectInviteStore` on primary button).
- Invite listener clears pending invite **before** navigating to success (`project_invitation_join_listener.dart`).

**Discover:** pending also uses `openProjectJoinRequestSentSuccess` (no `fromInviteLink`).

**Strings:** `projectJoinRequestSentTitle`, `projectJoinRequestSentSubtitle` in `app_strings.dart`.

**Tests:** `test/features/projects/project_joined_success_screen_test.dart` (immediate / pending discover / pending invite).

---

## 3. Key files

| Area | Path |
|------|------|
| Invite screen | `lib/features/invites/presentation/pages/project_invitation_screen.dart` |
| Join listener | `lib/features/invites/presentation/widgets/project_invitation_join_listener.dart` |
| Join cubit | `lib/features/invites/presentation/cubit/project_invitation_cubit.dart` |
| Success screen | `lib/features/projects/presentation/pages/project_joined_success_screen.dart` |
| Route args | `lib/app/router/route_args/project_joined_success_route_args.dart` |
| Nav helpers | `lib/features/project_detail/presentation/navigation/open_project_from_card.dart` |
| Join result | `lib/features/projects/domain/entities/join_project_result_entity.dart` |
| VFF remote | `lib/user/features/vff/data/datasources/vff_remote_data_source.dart` |

---

## 4. Suggested next steps (when resuming)

1. ~~Invite join flow~~ — done.
2. Continue **VFF API integration** (Sent inbox UI, hub refresh, `projectType` on cards, cleanup demo paths).
3. Optional: commit invite-flow changes if not already committed (`git status`).

---

## 5. User prefs from session

- Pending success = **same flow/image as public**, only copy + Done vs Open Project changes.
- Pill colors: #F5F0FE / #DDD0FC; type label #140930 w500.
