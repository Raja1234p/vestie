import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/main_app.dart';
import 'app/vestie_startup_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    debugPrint('main: runApp(VestieStartupShell)');
  }
  runApp(const VestieStartupShell(child: MainApp()));
}
