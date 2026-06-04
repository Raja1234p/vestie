import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:device_preview/device_preview.dart';
import 'app/main_app.dart';
import 'core/constants/api_constants.dart';
import 'core/di/service_locator.dart';
import 'core/auth/app_auth_session.dart';
import 'core/services/fcm_push_service.dart';
import 'core/services/project_invite_deep_link_service.dart';
import 'core/stripe/stripe_sdk_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Stripe (flutter_stripe): publishable key required before runApp.
  await StripeSdkInitializer.initialize();

  // Google Sign-In v7+: OAuth Web client ID from Google Cloud Console (used for `id_token` for your API).
  await GoogleSignIn.instance.initialize(
    serverClientId: ApiConstants.googleServerClientId,
  );


  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Dependency Injection
  await ServiceLocator.instance.init();

  await FcmPushService.initialize();

  await ProjectInviteDeepLinkService.instance.captureInitialInviteIfAny();
  await AppAuthSession.instance.refresh();

  const enableDevicePreview = !kReleaseMode;
  runApp(
    enableDevicePreview
        ? DevicePreview(
            enabled: enableDevicePreview,
            builder: (_) => const MainApp(enableDevicePreview: true),
          )
        : const MainApp(enableDevicePreview: false),
  );
}
