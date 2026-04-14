import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait (standard for fintech apps unless tablets are explicitly handled dynamically)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // TODO: Initialize Dependency Injection (e.g. GetIt)
  // await setupDependencies();

  runApp(const MainApp());
}
