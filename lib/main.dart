import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:device_preview/device_preview.dart';
import 'app/main_app.dart';
import 'core/constants/api_constants.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Google Sign In (v7.0.0+ requires initialization once)
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
