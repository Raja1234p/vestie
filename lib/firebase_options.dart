// Firebase options for Vestie (`app.vestie`).
// Values sourced from `android/app/google-services.json` and
// `ios/Runner/GoogleService-Info.plist`.
//
// Regenerate after Firebase console changes:
// `dart pub global activate flutterfire_cli && flutterfire configure`

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCQB2YRKOHAVEojIJyiFB_Vr2D3By2KEaM',
    appId: '1:106565886360:android:3488bf1fd2b3be9e9dcbed',
    messagingSenderId: '106565886360',
    projectId: 'vestie-2a93f',
    storageBucket: 'vestie-2a93f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDlp6GNdE5SkbWOCNiYLAfrANYS2ZK16ys',
    appId: '1:106565886360:ios:eebbecf05c40814d9dcbed',
    messagingSenderId: '106565886360',
    projectId: 'vestie-2a93f',
    storageBucket: 'vestie-2a93f.firebasestorage.app',
    iosBundleId: 'app.vestie',
  );
}
