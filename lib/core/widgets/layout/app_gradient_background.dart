import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

/// Splash screen gradient background.
/// Figma: vivid lighter purple at top → deep primary #4519A0 at bottom.
/// Used exclusively by SplashScreen.
class AppGradientBackground extends StatelessWidget {
  final Widget child;

  const AppGradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // white status bar icons on purple
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.splashGradientTop,    // #7038E8 — vivid violet-purple
              AppColors.splashGradientBottom, // #4519A0 — deep primary purple
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
