import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/cubit/nav_cubit.dart';

/// Top bar for the Discover tab.
/// The "←" arrow navigates back to the Home tab (tab 0) via NavCubit —
/// matching the Figma "← Discover" header design.
class DiscoverHeader extends StatelessWidget {
  const DiscoverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 65.h, 20.w, 20.h),

      child: Row(
        children: [
          // ── Back arrow ─────────────────────────────────────
          GestureDetector(
            onTap: () => context.read<NavCubit>().selectTab(0),
            child: Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20.w,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // ── Title ──────────────────────────────────────────
          Text(
            AppStrings.discoverTitle,
            style: GoogleFonts.lato(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          const Spacer(),

          // ── Bell icon ──────────────────────────────────────
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_outlined,
                size: 20.w, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
