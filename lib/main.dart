import 'package:flutter/material.dart';

import 'app/main_app.dart';
import 'bootstrap.dart';

Future<void> main() async {
  await AppBootstrap.run();
  runApp(const MainApp());
}
