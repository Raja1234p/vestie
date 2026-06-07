import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/main_app.dart';
import 'bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.run();
  if (kDebugMode) {
    debugPrint('main: runApp(MainApp)');
  }
  runApp(const MainApp());
}
