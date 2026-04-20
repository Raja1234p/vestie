import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/post_auth_header.dart';

/// Gradient header showing total contributed amount + bell icon.
class HomeHeader extends StatelessWidget {
  final double totalContributed;

  const HomeHeader({super.key, required this.totalContributed});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostAuthHeader(
          title: AppStrings.totalContributed,
          bottomGap: 0,
          titleStyle: GoogleFonts.lato(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          trailing: GestureDetector(
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
        ),  
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
          child: Text(
            '\$${_formatAmount(totalContributed)}',
            style: GoogleFonts.lato(
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
        ),
      ],
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
