import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';

/// Home-only gradient container so Home tuning won't affect other screens.
class HomeGradientBackground extends StatelessWidget {
  final Widget child;

  const HomeGradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final headerWidth = screenWidth - 50;
    final headerHeight = (headerWidth * 0.4).clamp(168.0, 220.0);

    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: Colors.white),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: SizedBox(
              width: headerWidth,
              height: headerHeight,
              child: Image.asset(
                AppAssets.appGradient,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
