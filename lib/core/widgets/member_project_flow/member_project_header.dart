import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';

/// Header for Vacation/Emergency member-facing screens (design parity with wizard).
/// Keeps navigation in core so user flows avoid depending on the leader wizard module.
class MemberFundFlowHeader extends StatelessWidget {
  final String title;
  final String? stepBadge;
  final Color badgeColor;
  final VoidCallback? onBack;

  const MemberFundFlowHeader({
    super.key,
    required this.title,
    this.stepBadge,
    this.badgeColor = Colors.white,
    this.onBack,
  });

  Color _badgeTextColor() {
    final lum = badgeColor.computeLuminance();
    return lum > 0.4 ? AppColors.textPrimary : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return PostAuthHeader(
      title: title,
      leading: AppBackButton(
        onPressed: onBack ?? () => context.pop(),
        color: AppColors.textPrimary,
      ),
      trailing: stepBadge == null
          ? null
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(100.r),
                border: badgeColor == Colors.white
                    ? Border.all(color: AppColors.purple300, width: 1)
                    : null,
              ),
              child: Text(
                stepBadge!,
                style: GoogleFonts.lato(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: _badgeTextColor(),
                ),
              ),
            ),
    );
  }
}
