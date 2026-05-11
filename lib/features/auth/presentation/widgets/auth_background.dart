import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_assets.dart';

/// Shared background for every auth screen.
/// Uses [AppAssets.authGradientBg] PNG stretched to fill the screen,
/// with white as the scaffold background colour.
class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppAssets.authGradientBg,
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}
