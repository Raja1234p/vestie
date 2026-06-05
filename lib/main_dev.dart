import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'app/main_app.dart';
import 'bootstrap.dart';

/// Debug entry with [DevicePreview]. Run via:
/// `flutter run -t lib/main_dev.dart`
Future<void> main() async {
  await AppBootstrap.run();
  runApp(
    DevicePreview(
      enabled: true,
      builder: (_) => const MainApp(enableDevicePreview: true),
    ),
  );
}
