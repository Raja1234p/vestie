# Feature: Authentication

**Owner folder:** `lib/features/auth/`

## Purpose

Login, registration, email verification, password reset, and session bootstrap integration with splash and agreement flows.

## Dependencies

- `AuthRepository`, `AuthRemoteDataSource`
- `AppAuthSession` (core)
- `flutter_secure_storage` via `inject_auth.dart`
- Related: `features/splash/`, `features/onboarding/`

## Routes

| Route | Screen |
|-------|--------|
| `/login` | `LoginScreen` |
| `/register` | `RegisterScreen` |
| `/verify` | `VerifyEmailScreen` |
| `/agreement` | `AgreementScreen` — Privacy Policy / Terms open in the system browser |
| `/forgot-password` | `ForgotPasswordScreen` |
| `/reset-password` | `ResetPasswordScreen` |

## Trace

`LoginScreen` → `LoginBloc` → `LoginUseCase` → `AuthRepository` → `POST /auth/login`

## See also

- [`PROJECT_FLOW_MAP.md`](../../../../PROJECT_FLOW_MAP.md) §1 Authentication
- [`FEATURE_MAP.md`](../../../../FEATURE_MAP.md) Auth & bootstrap
