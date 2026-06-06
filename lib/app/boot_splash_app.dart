import 'package:flutter/material.dart';

import '../core/widgets/layout/splash_brand_backdrop.dart';

/// Lightweight splash shown immediately after [runApp] while [AppBootstrap] runs.
///
/// Prevents the iOS black gap between the native launch screen and Flutter's
/// first routed [SplashScreen].
class BootSplashApp extends StatelessWidget {
  const BootSplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: SplashBrandBackdrop(),
      ),
    );
  }
}
