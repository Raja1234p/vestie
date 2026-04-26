import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../theme/app_colors.dart';

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
        child: Icon(
          Icons.arrow_back_rounded,
          size: AppDimens.backIconSize,
          color: color ?? AppColors.grey1100,
        ),
      ),
    );
  }
}
