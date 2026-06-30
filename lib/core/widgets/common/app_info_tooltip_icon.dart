import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';

/// Tap-to-show info icon using Flutter's [Tooltip] (mobile-friendly tap trigger).
class AppInfoTooltipIcon extends StatelessWidget {
  final String message;
  final String semanticsLabel;

  /// Optional bold title line above [message] (e.g. "Voting window").
  final String? title;
  final double size;
  final Color iconColor;

  const AppInfoTooltipIcon({
    super.key,
    required this.message,
    required this.semanticsLabel,
    this.title,
    this.size = 20,
    this.iconColor = AppColors.grey800,
  });

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.lato(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.grey800,
      height: 1.4,
    );
    final titleStyle = GoogleFonts.lato(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.authLabel,
      height: 1.4,
    );

    final titledMessage = title != null && title!.isNotEmpty;

    return Tooltip(
      message: titledMessage ? null : message,
      richMessage: titledMessage
          ? TextSpan(
              children: [
                TextSpan(text: '$title\n\n', style: titleStyle),
                TextSpan(text: message, style: bodyStyle),
              ],
            )
          : null,
      triggerMode: TooltipTriggerMode.tap,
      waitDuration: Duration.zero,
      showDuration: const Duration(seconds: 12),
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      constraints: BoxConstraints(maxWidth: 300.w),
      decoration: BoxDecoration(
        color: AppColors.infoTooltipSurface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.infoTooltipBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.infoTooltipShadow,
            offset: Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      textStyle: bodyStyle,
      child: Semantics(
        label: semanticsLabel,
        button: true,
        child: SizedBox(
          width: size.w,
          height: size.h,
          child: SvgPicture.asset(
            AppAssets.iconInfoCircle,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
