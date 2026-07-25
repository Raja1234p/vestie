# Permissions & platform QA (Android + iOS)

Test on **physical devices** (simulators work but camera/push differ).

**App behavior:** Camera → `Permission.camera`; Gallery (iOS) → `Permission.photos` (limited OK). Both use official `status.isDenied` → `request()` callbacks; soft deny → toast; permanently denied → Open Settings. Android gallery → system photo picker (no runtime Photos permission). Podfile: `PERMISSION_CAMERA=1`, `PERMISSION_PHOTOS=1`.

---

## Manifest / plist (already in project)

| Permission | Android | iOS |
|------------|---------|-----|
| Internet | `INTERNET` | — |
| Camera | `CAMERA` | `NSCameraUsageDescription` |
| Photo library | `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE` (≤32) | `NSPhotoLibraryUsageDescription` |
| Notifications | `POST_NOTIFICATIONS` (13+) | `NSUserNotificationsUsageDescription` + `remote-notification` background mode |
| FCM | `google-services.json` | `GoogleService-Info.plist` |

---

## 1. Notifications (FCM)

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| P1 | First login → dashboard | Fresh install, login | System prompt (iOS) and/or in-app “Enable notifications” once | |
| P2 | Allow | Tap Allow / Enable | Token registers (`FcmPushService.syncDeviceToken`); no crash | |
| P3 | Deny | Deny system prompt | App usable; optional in-app prompt; not looping every second | |
| P4 | Re-enable Android | Settings → Apps → Vestie → Notifications → ON → reopen app | Token sync on dashboard | |
| P5 | Re-enable iOS | Settings → Vestie → Notifications → Allow | Token sync | |
| P6 | Logout | Logout | `DELETE` device token; logout clears session | |
| P7 | Push delivery | Backend/Firebase test message | Tray notification (optional; needs server + certs) | |

### How to enable after deny

| OS | Path |
|----|------|
| **Android 13+** | Settings → Apps → Vestie → Notifications → On |
| **iOS** | Settings → Vestie → Notifications → Allow Notifications |

In-app: dashboard may show **Enable** dialog once; profile flows do not block if denied.

---

## 2. Camera (profile photo)

**Entry:** Profile tab → tap avatar → **Take Photo** (or Edit Profile → avatar).

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| C1 | First request | Tap Take Photo | System camera permission dialog | |
| C2 | Allow | Allow → take photo → confirm | Photo uploads or shows API error (not permission loop) | |
| C3 | Deny once | Don’t allow | **Open Settings** dialog with instructions | |
| C4 | Deny permanently | Deny + “Don’t ask again” (Android) or deny twice (iOS) | **Open Settings** dialog with instructions | |
| C5 | Enable in settings | Settings → Vestie → Camera → On → retry | Picker opens | |

---

## 3. Photo library / gallery

**Entry:** Profile → avatar → **Choose from Gallery** (or Edit Profile).

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| G1 | First request | Tap gallery | Photos permission dialog | |
| G2 | Allow | Pick image | Preview / upload works | |
| G3 | Deny | Deny access | **Open Settings** dialog | |
| G4 | Limited (iOS) | Select “Limited Photos” | Can still pick from allowed set | |
| G5 | Re-enable | Settings → Vestie → Photos → Full Access | Retry succeeds | |

---

## 4. Android-specific

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| A1 | Debug APK install | `flutter install` or APK sideload | Installs; opens | |
| A2 | Back gesture | Navigate deep → system back | Correct `go_router` pop | |
| A3 | Low memory | Background app → reopen | Session restored or re-login | |

---

## 5. iOS-specific

| # | Test | Steps | Expected | Result |
|---|------|--------|----------|--------|
| I1 | Debug on device | `flutter run` from Mac | Builds; no signing error | |
| I2 | PaymentSheet | Deposit confirm | Apple Pay may appear; card entry works | |
| I3 | WebView KYC | Withdraw → Verify identity | WebView loads HTTPS onboarding | |

---

## 6. Build verification (zero compile errors)

Run before each QA pass:

```bash
flutter pub get
flutter analyze
flutter build apk --debug
# On Mac only:
flutter build ios --debug --no-codesign
```

| Command | Pass criteria |
|---------|----------------|
| `flutter analyze` | **0 errors** |
| Android build | APK succeeds |
| iOS build | Xcode archive succeeds (with signing for TestFlight) |

---

## Sign-off

| Area | Android | iOS |
|------|---------|-----|
| Notifications | ☐ | ☐ |
| Camera | ☐ | ☐ |
| Gallery | ☐ | ☐ |
| Build | ☐ | ☐ |

**Notes:**

_______________________________________________
