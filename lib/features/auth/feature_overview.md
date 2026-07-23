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

Apple Sign-In (`POST /auth/apple`): Apple’s identity token never includes the person name. Production swagger `ExternalLoginRequest` only allows `idToken` / `deviceName` / `ipAddress` (`additionalProperties: false`), so the backend cannot create `firstName`/`lastName` from the token alone — only `userName` (from email claims) appears on a brand-new account. Per Apple/`sign_in_with_apple`, `givenName`/`familyName` arrive only on the **first** Apple ID ↔ app consent (not “first Vestie account”). The app caches them immediately, then `PUT /users/me` as JSON `UpdateProfileRequest` when profile `firstName`/`lastName` are empty. Sync failure does not fail Apple login. Loader stays active for the full chain.

**Re-test name sync:** Settings → Apple ID → Sign in with Apple → Vestie → Stop Using Apple ID, then sign in again and share name on the Apple sheet. Check logs for `hasGivenName` / `hasFamilyName`.

## See also

- [`PROJECT_FLOW_MAP.md`](../../../../PROJECT_FLOW_MAP.md) §1 Authentication
- [`FEATURE_MAP.md`](../../../../FEATURE_MAP.md) Auth & bootstrap
