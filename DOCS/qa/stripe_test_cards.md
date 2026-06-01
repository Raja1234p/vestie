# Stripe test cards (QA / staging only)

Use these only when the backend uses **Stripe test mode** (`pk_test_…` from `GET /stripe/config`).  
**Never use test cards in production** (live `pk_live_…`).

Official reference: [Stripe testing docs](https://docs.stripe.com/testing)

---

## Default success card (most deposit tests)

| Field | Value |
|-------|--------|
| **Number** | `4242 4242 4242 4242` |
| **Expiry** | Any **future** date, e.g. `12/34` |
| **CVC** | Any 3 digits, e.g. `123` |
| **ZIP** (if asked) | Any 5 digits, e.g. `12345` |
| **Name** | Any name |

In PaymentSheet, type digits without spaces or with spaces — both work.

---

## Common test scenarios

| Scenario | Card number | Expiry | CVC | Expected in app |
|----------|-------------|--------|-----|-----------------|
| **Success** | `4242 4242 4242 4242` | `12/34` | `123` | PaymentSheet completes → poll → deposit success |
| **Decline (generic)** | `4000 0000 0000 0002` | `12/34` | `123` | Payment fails; snackbar/error; wallet unchanged |
| **Insufficient funds** | `4000 0000 0000 9995` | `12/34` | `123` | Decline |
| **3D Secure auth required** | `4000 0025 0000 3155` | `12/34` | `123` | Extra auth step in sheet → then success |
| **3D Secure auth fails** | `4000 0000 0000 3220` | `12/34` | `123` | Fails after challenge |

---

## International / brand variants (optional)

| Brand | Number |
|-------|--------|
| Visa | `4242 4242 4242 4242` |
| Mastercard | `5555 5555 5555 4444` |
| Amex | `3782 822463 10005` (CVC **4** digits) |

---

## Week 5 QA script (copy-paste)

1. Login → accept risk disclaimer.  
2. Wallet → note balance **B0**.  
3. Deposit **$50.00** → Confirm → PaymentSheet.  
4. Card: `4242 4242 4242 4242`, exp `12/34`, CVC `123`.  
5. Wait for success screen.  
6. Wallet → balance **≥ B0 + $50** (minus any fees if API applies fee on deposit).  
7. Repeat with `4000 0000 0000 0002` → must **not** increase balance.

---

## Production checklist

| Item | Staging | Production |
|------|---------|------------|
| `GET /stripe/config` key | `pk_test_…` | `pk_live_…` |
| Cards | Table above | Real user cards |
| Simulated `POST /wallet/deposit` | Backend dev only | **Not used by app** |
| PaymentSheet | Required | Required |

If PaymentSheet does not open, check backend `POST /wallet/deposit/intent` returns non-empty **`clientSecret`**.
