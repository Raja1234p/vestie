import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'core/auth/app_auth_session.dart';
import 'core/constants/api_constants.dart';
import 'core/di/service_locator.dart';
import 'core/services/fcm_push_service.dart';
import 'core/services/project_invite_deep_link_service.dart';
import 'core/stripe/stripe_sdk_initializer.dart';
import 'firebase_options.dart';

/// Shared cold-start initialization for [main.dart] and [main_dev.dart].
abstract final class AppBootstrap {
  AppBootstrap._();

  static Future<void> run() async {
    _enableAndroidPhotoPicker();

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FcmPushService.attachBackgroundMessageHandler();
    _log('start');
    await StripeSdkInitializer.initialize();
    _log('stripe ready');

    await GoogleSignIn.instance.initialize(
      serverClientId: ApiConstants.googleServerClientId,
    );
    _log('google sign-in ready');

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    await ServiceLocator.instance.init();
    _log('service locator ready');

    await FcmPushService.initialize();
    _log('fcm ready');

    await ProjectInviteDeepLinkService.instance.captureInitialInviteIfAny();
    _log('invite deep link capture done');

    await AppAuthSession.instance.syncFromStorage();
    _log('auth session synced — bootstrap complete');
  }

  /// Gallery picks go through the Android system photo picker, so the app does
  /// not need READ_MEDIA_IMAGES (Play Photo and Video Permissions policy).
  static void _enableAndroidPhotoPicker() {
    final platform = ImagePickerPlatform.instance;
    if (platform is ImagePickerAndroid) {
      platform.useAndroidPhotoPicker = true;
    }
  }

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('AppBootstrap: $message');
    }
  }
}
