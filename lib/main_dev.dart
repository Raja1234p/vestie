import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'app/main_app.dart';
import 'app/vestie_startup_shell.dart';

/// Debug entry with [DevicePreview]. Run via:
/// `flutter run -t lib/main_dev.dart`
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    VestieStartupShell(
      child: DevicePreview(
        enabled: true,
        builder: (context) => MainApp(
          previewLocale: DevicePreview.locale(context),
          previewAppBuilder: DevicePreview.appBuilder,
        ),
      ),
    ),
  );
}
