# Final audit — Weeks 4, 5, 7 (remaining manual tests)

**Backend (app):** `https://vestie-backend-prod-hsaghpaedggzhhh9.centralus-01.azurewebsites.net/api/v1`  
**Review date:** 2026-06-02

## Integration verdict (code)

| Week | Production-ready in app? | Notes |
|------|--------------------------|--------|
| **4** | **Yes** | `GET /wallet`, `POST /projects/{id}/contributions`, `GET /projects/{id}/pot`, SignalR, 15% fee + $5 min client-side |
| **5** | **Yes** | Deposit intent + PaymentSheet + poll; payment methods CRUD + primary; SetupIntent add card |
| **7** | **Yes** | Withdraw preview/submit/poll; KYC browser; bank link/list/delete/default; announcements; notifications + FCM |

**UI note (2026-06):** Wallet tab no longer shows **Locked in projects** or **Pending withdrawal** rows (API fields still parsed).

---

## Already tested (your sign-off)

| Area | Flow |
|------|------|
| Week 5 | Add payment method, set primary, delete |
| Week 5 | Deposit (PaymentSheet) |
| Week 7 | Add bank account, set default, delete |
| Week 7 | Withdraw (amount → method → bank → confirm) |

---

## Still test before production — priority order

### P0 — Must run (money + membership)

1. **Week 4 — Contribute to project** (`POST /projects/{id}/contributions`)  
   - Entry: active project → **Contribute**  
   - Min **$5**; confirm **15%** fee on confirm screen  
   - Pay from **wallet** when balance ≥ amount + fee  
   - Success → project **pot / raised** updates  
   - Wallet balance decreases by **amount + fee**

2. **Week 7 — Withdraw variants** (if you only tested one rail)  
   - **Standard:** 0% fee, confirm copy  
   - **Instant:** 1.5% fee, e.g. `$10` → fee `$0.15`, receive `$9.85`  
   - Poll until **Completed** (or clear failure); check **recent activity** on wallet

3. **Week 7 — KYC** (if withdraw worked without re-testing)  
   - Fresh user: withdraw → browser KYC → `GET /kyc/status` **Verified** → withdraw succeeds

4. **Risk disclaimer**  
   - New session / user: **Deposit**, **Withdraw**, **Contribute** blocked until accepted (`POST /users/me/risk-disclaimer`)

### P1 — Should run (Week 7 product)

5. **Announcements** (leader/co-leader account)  
   - `POST /projects/{id}/announcements` create  
   - List on project detail  
   - `DELETE` announcement

6. **Notifications**  
   - `GET /notifications` inbox  
   - Tap item → `POST /notifications/mark-read`  
   - Unread count decreases

7. **Contribute — insufficient wallet**  
   - Total > balance → payment picker; card path prompts **deposit** (wallet-only API)

### P2 — Optional / ops

8. **Week 4 — SignalR** — two devices, same project: contribute on A → pot updates on B  
9. **Week 4 — Wallet** — recent activity, **View all**, retry on API error  
10. **FCM** — push delivery (backend + real device)  
11. **Deposit** — second card, idempotency (double-tap confirm once)

---

## Quick path cheat sheet

| You want to test | Where in app |
|------------------|--------------|
| Contribute | Project detail → **Contribute** |
| Deposit | Wallet → **Deposit Funds** |
| Withdraw | Wallet → **Withdraw Funds** |
| Cards | Profile → **Payment Methods** |
| Banks | Profile → **My Accounts** (or withdraw bank picker → Add) |
| KYC | Triggered from **Withdraw** when not verified |
| Announcements | Project detail (leader) → menu → Add announcement |
| Notifications | Header bell → notifications list |

---

## Reference QA checklists

- [week_4_qa.md](week_4_qa.md) — wallet, contribute, pot, SignalR  
- [week_5_qa.md](week_5_qa.md) — Stripe, deposit, payment methods  
- [week_7_qa.md](week_7_qa.md) — withdraw, KYC, banks, announcements, notifications  
- [production_readiness_review.md](production_readiness_review.md) — full integration matrix  
