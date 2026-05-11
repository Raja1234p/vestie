import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_dimens.dart';

/// Single back control for all screens: same icon, size, and tap behavior.
class AppBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? color;

  const AppBackButton({
    super.key,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = AppDimens.backIconSize;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cachePx = math.max(1, (size * dpr).round());
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Image.asset(
          AppAssets.iconArrowBack,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          cacheWidth: cachePx,
          cacheHeight: cachePx,
        ),
      ),
    );
  }
}
