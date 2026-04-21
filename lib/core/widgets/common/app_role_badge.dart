import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vestie/core/constants/app_assets.dart';
import '../../theme/app_colors.dart';

/// Reusable role badge — shows "👑 Leader" / "👑 Co Leader".
/// Used in: MemberRow; reusable in any screen that shows roles.
enum AppRoleType { leader, coLeader }

class AppRoleBadge extends StatelessWidget {
  final AppRoleType role;

  const AppRoleBadge({super.key, required this.role});

  String get _label =>
      role == AppRoleType.leader ? 'Leader' : 'Co Leader';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.purple800,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(AppAssets.crown),
          SizedBox(width: 3.w),
          Text(
            _label,
            style: GoogleFonts.lato(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral100,
            ),
          ),
        ],
      ),
    );
  }
}
