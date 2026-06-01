# Week 7 QA — Withdraw, KYC, banks, announcements, notifications, FCM

**Implemented in app:** Withdraw preview/submit/poll, KYC status + WebView onboarding, bank list + picker, wallet `pendingWithdrawal` + `recentTransactions`, project announcements create/list/delete, notifications list, FCM register/unregister, shimmer on wallet/notifications/payment methods/bank/KYC load.

**Tester:** _______________ **Date:** _______________ **Build:** _______________ **Device:** _______________

**Runbook:** [manual_test_runbook.md](manual_test_runbook.md) · **Permissions:** [permissions_and_platform_qa.md](permissions_and_platform_qa.md)

---

## Known gaps

| Item | Status |
|------|--------|
| Link bank (`POST /bank-accounts`) | **In app** — WebView onboarding (`/bank/link-onboarding`); Add bank on empty picker |
| Wallet / notifications API failure | Retry UI (`AppErrorView` + Try Again); no mock data |
| FCM push delivery | Token register/unregister in app; actual push requires backend + device |
| Project pot on detail | Wired via `GET /pot` + SignalR; contributor count on info card |

---

## 0. Prerequisites

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 0.1 | Disclaimer + funded wallet | Week 4–5 complete | Balance ≥ $10 for withdraw | |
| 0.2 | KYC verified | Backend: `GET /kyc/status` → Verified, payouts enabled | Or complete 7.2 first | |
| 0.3 | Linked bank | At least one bank on account (`GET /bank-accounts`) | Required for withdraw | |
| 0.4 | Leader account | Separate login for announcement tests | GroupLeader or CoLeader | |

---

## 1. KYC (`GET /kyc/status`, `POST /kyc/start`)

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 1.1 | Shimmer | Withdraw without KYC → **Verify identity** → onboarding | `KycWebViewShimmer` while starting | |
| 1.2 | WebView loads | After start | Stripe/Connect onboarding page in WebView | |
| 1.3 | Complete onboarding | Finish Stripe flow until redirect | App pops back with success (`true`) | |
| 1.4 | Retry withdraw | Withdraw again | Passes KYC gate (if Verified on server) | |
| 1.5 | Cancel | Back from KYC screen | Returns without crash; withdraw still blocked if not verified | |

---

## 2. Bank accounts (`GET /bank-accounts`)

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 2.1 | No banks | Zero banks → Withdraw → continue → bank picker | Empty state + **Add bank account** → Stripe WebView | |
| 2.2 | Shimmer | With banks → withdraw → bank picker | `BankAccountListShimmer` on load | |
| 2.3 | List | Bank picker screen | Shows `displayName`; default label if applicable | |
| 2.4 | Select bank | Tap a bank | Navigates to withdraw confirmation | |
| 2.5 | Remove bank | If remove UI exists in settings | **SKIP** if no link/remove screen in profile | |

---

## 3. Withdraw flow

**Path:** Wallet → **Withdraw Funds** → amount (min **$10**) → Standard/Instant → bank → confirm.

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 3.1 | Min amount | Enter `$9` → continue | Blocked (min $10) | |
| 3.2 | Standard preview | $50, **Standard** → confirm screen | Fee **0%**; net = amount | |
| 3.3 | Instant preview | $50, **Instant** → confirm screen | Fee **1.5%** ($0.75 on $50) | |
| 3.4 | Insufficient balance | Amount > available | Error before or on submit | |
| 3.5 | Submit | Confirm withdraw | Success or Processing screen | |
| 3.6 | Poll | Wait on success/processing | Eventually **Completed** or clear failure | |
| 3.7 | Wallet after | Wallet tab | Balance reduced; **Pending withdrawal** banner if API returns `pendingWithdrawal` > 0 | |
| 3.8 | Recent activity | Wallet recent list | Withdrawal appears in activity if API returns it | |
| 3.9 | No bank selected | Reach confirm without bank | Error “Select a bank account” | |
| 3.10 | Disclaimer | Without disclaimer | Gated at wallet flow start | |

---

## 4. End-to-end withdrawal script (from integration plan)

| Step | Action | Expected | Result |
|------|--------|----------|--------|
| 1 | Login + disclaimer | OK | |
| 2 | KYC verified | `GET /kyc/status` OK | |
| 3 | Bank linked | `GET /bank-accounts` non-empty | |
| 4 | Fund wallet if needed | Deposit or dev credit | |
| 5 | Note `GET /wallet` balance | ≥ withdrawal amount | |
| 6 | Preview Standard or Instant | Fees match rules | |
| 7 | `POST /wallet/withdrawals` | Withdrawal id returned | |
| 8 | Poll until terminal | Completed or Failed | |
| 9 | `GET /wallet` | Balance down; pending updated | |

---

## 5. Project announcements

**Leader/co-leader** on project detail.

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 5.1 | Load list | Open project with announcements | Cards show **heading + content** from API (not project description only) | |
| 5.2 | Empty | Project with none | Placeholder “Any announcement will come up here” | |
| 5.3 | Create | ⋯ menu → **Add Announcement** → heading + content → create | Success; back to detail; new item visible after refresh | |
| 5.4 | Delete | Swipe delete on announcement (moderator) | Removed; list refreshes | |
| 5.5 | Member view | Member opens same project | Sees announcements; cannot delete | |

---

## 6. Notifications (`GET /notifications`)

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 6.1 | Shimmer | Profile → Notifications (or app route) | `NotificationListShimmer` | |
| 6.2 | List | After load | Items from API (title, body, time) | |
| 6.3 | API failure | Offline open | Error message + **Try Again** (no sample list) | |
| 6.4 | Mark read | Tap unread notification (API list, not fallback samples) | Row styling updates; unread count decreases | |
| 6.4b | Fallback mode | Force API failure → sample list | Tap does **not** call mark-read (expected) | |
| 6.5 | Empty | Account with no notifications | Empty state illustration + copy | |

---

## 7. FCM (`POST` / `DELETE /notifications/device-token`)

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 7.1 | Config files | Build includes `google-services.json` + `GoogleService-Info.plist` | App builds without Firebase init crash | |
| 7.2 | Register on login | Login → reach dashboard | Backend receives device token (check logs/admin) | |
| 7.3 | Logout unregister | Logout | Token removed on server (check logs) | |
| 7.4 | Push delivery | Send test push from Firebase/backend | Notification appears (system tray) — **optional** | |
| 7.5 | Permission allow | First launch / dashboard | System or in-app enable → token registers | |
| 7.6 | Permission deny | Deny notifications | App usable; [permissions QA](permissions_and_platform_qa.md) re-enable steps | |

---

## 8. Shimmer regression (Week 7 screens)

| Screen | Expected skeleton | Result |
|--------|-------------------|--------|
| Wallet tab (initial) | `WalletTabShimmer` | |
| Notifications | `NotificationListShimmer` | |
| Payment methods | `PaymentCardListShimmer` | |
| Select bank account | `BankAccountListShimmer` | |
| KYC onboarding start | `KycWebViewShimmer` | |

---

## 9. Cross-week regression

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| 9.1 | Deposit still works | Week 5 deposit | OK | |
| 9.2 | Contribute still works | Week 4 contribute | OK | |
| 9.3 | Home/Discover | Tab switch | OK | |
| 9.4 | Logout clears session | Logout → login | Caches cleared; no stale wallet on wrong user | |

---

## Week 7 sign-off

| Check | PASS / FAIL |
|-------|-------------|
| KYC WebView + withdraw gate | |
| Withdraw preview fees (0% / 1.5%) | |
| Withdraw submit + wallet update | |
| Announcements list / create / delete | |
| Notifications list loads | |
| FCM token register on login | |

**Notes:**

_______________________________________________

_______________________________________________
