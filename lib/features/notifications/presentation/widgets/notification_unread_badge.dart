import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

enum NotificationUnreadBadgeStyle {
  /// Notifications screen sub-header pill.
  header,

  /// Compact pill overlaid on the 32×32 bell icon.
  iconOverlay,
}

class NotificationUnreadBadge extends StatelessWidget {
  const NotificationUnreadBadge({
    super.key,
    required this.count,
    this.style = NotificationUnreadBadgeStyle.header,
  });

  final int count;
  final NotificationUnreadBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final label = count > 99 ? '99+' : '$count';
    final isIconOverlay = style == NotificationUnreadBadgeStyle.iconOverlay;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isIconOverlay ? 4.w : 10.w,
        vertical: isIconOverlay ? 1.h : 4.h,
      ),
      constraints: isIconOverlay ? BoxConstraints(minWidth: 14.w) : null,
      decoration: BoxDecoration(
        color: AppColors.purple900,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          fontSize: isIconOverlay ? 9.sp : 12.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
