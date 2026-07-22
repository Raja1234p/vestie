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

When login returns `400` ProblemDetails with title **Email not verified**, the app does **not** show the error dialog. It resends the OTP (`POST` resend-code), opens the same verify screen as registration (`VerifyFlow.registration`), then agreement via the existing verify success path. Google/Apple login and other login errors are unchanged.

Apple Sign-In (`POST /auth/apple`) then, when Apple returns `givenName`/`familyName` (first authorization only) and `GET /users/me` has an empty name, calls the same `PUT /users/me` multipart as Edit Profile (`firstName`, `lastName`, `fullName`, `userName`) so the profile is filled without changing Google or email/password flows. Profile sync failures do not fail Apple login. `LoginAppleLoading` / `RegisterAppleLoading` stay active for the full chain (Apple sheet → auth → optional me sync → disclaimer), with the Apple button spinner plus `AppLoadingOverlay` so the UI stays blocked while those APIs run.

## See also

- [`PROJECT_FLOW_MAP.md`](../../../../PROJECT_FLOW_MAP.md) §1 Authentication
- [`FEATURE_MAP.md`](../../../../FEATURE_MAP.md) Auth & bootstrap
