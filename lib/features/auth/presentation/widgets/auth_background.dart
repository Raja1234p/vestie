import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

/// Shared background for every auth screen.
///
/// Uses the app-wide 3-stop gradient (#CEBEFB → #E0D6FC → #F8F7FA):
///   - Top ~30 %  : rich lavender  (title / hero zone clearly purple)
///   - Bottom 70 %: fades to near-white (form / content area looks light)
class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, // dark icons on light lavender bg
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.appBackgroundGradient,
          ),
          child: SafeArea(child: child),
        ),
      ),
    );
  }
}
