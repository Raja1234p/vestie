# Vestie — Dependency Map

How dependencies are registered and consumed. Registration lives in `lib/core/di/`.

---

## Registration modules

| File | Registers |
|------|-----------|
| `inject_core.dart` | Dio, secure storage, prefs, `BaseApiClient`, connectivity, project local cache |
| `inject_auth.dart` | Auth repository + auth use cases |
| `inject_project.dart` | Projects, detail, actions, pot, announcements, voting blocs |
| `inject_wallet.dart` | Wallet, Stripe, payments, KYC, bank, deposit, withdraw |
| `inject_notifications.dart` | Notifications + FCM token APIs |
| `inject_user.dart` | Contributions, borrow, VFF, home summary |
| `service_locator.dart` | Facade fields + `init()` orchestration + bloc factories |

**Init order:** core → auth → project → wallet → notifications → user features

---

## ServiceLocator consumption

| Consumer | Access pattern |
|----------|----------------|
| Cubits / Blocs (factory) | Constructor injection from route `BlocProvider` |
| `MainApp` | `WalletCubit`, `CreateProjectCubit` via `ServiceLocator.instance` |
| Navigation helpers | `createProjectDetailBloc()`, `createContributeBloc()` |
| Prefetch (`core/services/*_prefetch.dart`) | `getWalletUseCase`, `listPaymentMethodsUseCase`, etc. |
| Interceptors | `secureStorage` via `DioClient` |

---

## Network stack

```text
Widget → Cubit/Bloc → UseCase → Repository → RemoteDataSource → BaseApiClient/DioClient
                                                              ↓
                                                    AuthInterceptor (Bearer)
```

| Client | Used by |
|--------|---------|
| `DioClient` | Auth, borrow, legacy project detail datasource |
| `BaseApiClient` | Wallet, VFF, notifications, project actions, contributions |

---

## Platform services (not repositories)

| Service | File | Responsibility |
|---------|------|----------------|
| FCM push | `core/services/fcm_push_service.dart` | Firebase init, token sync, foreground/background notification display |
| Push tap routing | `core/services/notifications/push_notification_router.dart` | Notification tap → `GoRouter` navigation (no `BuildContext`); see `DOCS/push_notification_routing.md` |
| Deep links | `core/services/project_invite_deep_link_service.dart` | `/join/{code}` capture |
| Invite parser | `core/services/project_invite_link_parser.dart` | URI parsing |
| Projects SignalR | `core/realtime/projects_signalr_service.dart` | `/hubs/projects` |
| Wallet SignalR | `core/realtime/wallet_signalr_service.dart` | `/hubs/wallet` |
| Stripe SDK | `core/stripe/stripe_payment_service.dart` | PaymentSheet / SetupIntent |
| Prefetch | `core/services/*_prefetch.dart` | Warm caches on tab activation |

**Rule:** Repositories do not import `flutter/material.dart` or handle navigation.

---

## App-level bloc lifetime

| Bloc/Cubit | Lifetime | Created in |
|------------|----------|------------|
| `CreateProjectCubit` | App session | `MainApp` |
| `WalletCubit` | App session | `MainApp` |
| `ProjectDetailBloc` | Per detail route | `ServiceLocator.createProjectDetailBloc()` |
| `ContributeBloc` | Per contribute flow | `ServiceLocator.createContributeBloc()` |
| `HomeBloc` | Per `HomeScreen` | `HomeScreen` state |
| `DiscoverCubit` | Per `DiscoverScreen` | `DiscoverScreen` state |

---

## Caches (domain memory)

| Cache | File | Cleared on logout |
|-------|------|-------------------|
| Wallet balance | `wallet/domain/wallet_balance_cache.dart` | Yes |
| Payment methods | `features/payment_methods/domain/payment_methods_cache.dart` | Yes |
| Bank accounts | `features/bank_accounts/domain/bank_accounts_cache.dart` | Yes |
| KYC status | `features/kyc/domain/kyc_status_cache.dart` | Yes |
