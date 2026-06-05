import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'core/auth/app_auth_session.dart';
import 'core/constants/api_constants.dart';
import 'core/di/service_locator.dart';
import 'core/services/fcm_push_service.dart';
import 'core/services/project_invite_deep_link_service.dart';
import 'core/stripe/stripe_sdk_initializer.dart';

/// Shared cold-start initialization for [main.dart] and [main_dev.dart].
abstract final class AppBootstrap {
  AppBootstrap._();

  static Future<void> run() async {
    WidgetsFlutterBinding.ensureInitialized();

    await StripeSdkInitializer.initialize();

    await GoogleSignIn.instance.initialize(
      serverClientId: ApiConstants.googleServerClientId,
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    await ServiceLocator.instance.init();

    await FcmPushService.initialize();

    await ProjectInviteDeepLinkService.instance.captureInitialInviteIfAny();
    await AppAuthSession.instance.syncFromStorage();
  }
}
