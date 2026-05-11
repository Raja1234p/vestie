import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';

/// Tappable square: [AppAssets.iconTickSwitchOn] when [value] is true, empty bordered tile when false.
class AppTickSwitch extends StatelessWidget {
  const AppTickSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final side = 24.w;
    final radius = 4.0 * (side / 24);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cachePx = math.max(1, (side * dpr).round());
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: side,
          height: side,
          child: Center(
            child: value
                ? Image.asset(
                    AppAssets.iconTickSwitchOn,
                    width: side,
                    height: side,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    gaplessPlayback: true,
                    cacheWidth: cachePx,
                    cacheHeight: cachePx,
                  )
                : Container(
                    width: side,
                    height: side,
                    decoration: BoxDecoration(
                      // Subtle fill + mid-grey border so the empty tile reads on white
                      // and on light grey card backgrounds (avoids “lost” 1px hairlines).
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(radius),
                      border: Border.all(
                        color: AppColors.grey500,
                        width: 1.5,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
