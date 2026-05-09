import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_dimens.dart';
import '../../theme/app_colors.dart';
import 'app_svg_icon.dart';

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
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: AppSvgIcon(
          assetPath: AppAssets.iconArrowBack,
          size: AppDimens.backIconSize,
          color: color ?? AppColors.grey1100,
        ),
      ),
    );
  }
}
