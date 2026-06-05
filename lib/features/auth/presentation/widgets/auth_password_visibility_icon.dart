import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';

/// Suffix icon for auth password fields: design PNG when obscured, SVG open eye when visible.
///
/// Uses [FilterQuality.none] and decode size tied to [MediaQuery.devicePixelRatio] so the
/// bitmap stays sharp at the target logical size.
class AuthPasswordVisibilityIcon extends StatelessWidget {
  const AuthPasswordVisibilityIcon({
    super.key,
    required this.passwordVisible,
    required this.logicalSize,
  });

  /// `true` when the password is shown (open-eye state).
  final bool passwordVisible;

  /// Edge length in logical pixels (e.g. `20.w` from ScreenUtil).
  final double logicalSize;

  @override
  Widget build(BuildContext context) {
    if (passwordVisible) {
      return AppSvgIcon(
        assetPath: AppAssets.authPasswordVisible,
        size: logicalSize,
        color: AppColors.inputFieldIcon,
      );
    }
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cachePx = math.max(1, (logicalSize * dpr).round());
    return Image.asset(
      AppAssets.authPasswordHidden,
      width: logicalSize,
      height: logicalSize,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      gaplessPlayback: true,
      cacheWidth: cachePx,
      cacheHeight: cachePx,
      alignment: Alignment.center,
    );
  }
}
