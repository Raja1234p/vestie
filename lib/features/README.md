# `lib/features/` — Shared modules

Code used by **all roles** (leader, co-leader, member).

| Module | Purpose |
|--------|---------|
| `auth`, `splash`, `onboarding` | Bootstrap & session |
| `dashboard` | Tab shell |
| `wallet`, `payment_methods`, `kyc`, `bank_accounts`, `stripe` | Money & compliance |
| `projects`, `invites`, `project_detail`, `project_pot` | Projects & pots |
| `notifications`, `profile` | Account & inbox |

Member-only UI → `lib/user/features/`. Leader-only → `lib/leader/features/`.

See [FEATURE_MAP.md](../../FEATURE_MAP.md).
