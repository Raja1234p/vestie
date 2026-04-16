import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_assets.dart';

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
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                AppAssets.authLoginGradient,
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}
