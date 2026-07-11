import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_dimens.dart';

/// Single back control for all screens: same icon, size, and tap behavior.
class AppBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? color;
  final double? size;

  const AppBackButton({
    super.key,
    required this.onPressed,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedSize = size ?? AppDimens.backIconSize;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cachePx = math.max(1, (resolvedSize * dpr).round());
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: color == null
            ? Image.asset(
                AppAssets.iconArrowBack,
                width: resolvedSize,
                height: resolvedSize,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                cacheWidth: cachePx,
                cacheHeight: cachePx,
              )
            : ColorFiltered(
                colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
                child: Image.asset(
                  AppAssets.iconArrowBack,
                  width: resolvedSize,
                  height: resolvedSize,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  cacheWidth: cachePx,
                  cacheHeight: cachePx,
                ),
              ),
      ),
    );
  }
}
