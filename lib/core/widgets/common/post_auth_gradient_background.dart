import 'package:flutter/material.dart';
import '../../constants/app_assets.dart';

/// Shared gradient background for all post-auth screens.
class PostAuthGradientBackground extends StatelessWidget {
  final Widget child;

  const PostAuthGradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double headerWidth = width - 40;
    final double headerHeight = headerWidth * (128 / 402);

    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: Colors.white),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            AppAssets.appGradient,
            fit: BoxFit.cover,
          ),
        ),
        child,
      ],
    );
  }
}
