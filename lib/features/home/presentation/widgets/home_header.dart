import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// Gradient header showing total contributed amount + bell icon.
class HomeHeader extends StatelessWidget {
  final double totalContributed;

  const HomeHeader({super.key, required this.totalContributed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 52.h, 20.w, 24.h),
      decoration: const BoxDecoration(
        gradient: AppColors.appBackgroundGradient,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.totalContributed,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: AppColors.authSubtitle,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '\$${_formatAmount(totalContributed)}',
                  style: GoogleFonts.inter(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 20.w,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats as comma-separated integer: 4223 → "4,223"
  String _formatAmount(double v) {
    final parts = v.toStringAsFixed(0).split('');
    final buf = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buf.write(',');
      buf.write(parts[i]);
    }
    return buf.toString();
  }
}
