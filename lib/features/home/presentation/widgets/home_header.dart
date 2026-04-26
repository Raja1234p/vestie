import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
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
            onTap: () => context.push(AppRoutes.notifications),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: SvgPicture.asset(
                AppAssets.iconNotification,
                width: 24.w,
                height: 24.w,
                fit: BoxFit.contain,
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
