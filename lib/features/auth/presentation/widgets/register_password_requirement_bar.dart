import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';

/// Pill under confirm password — hint copy + static trailing checkmark (design PNG).
class RegisterPasswordRequirementBar extends StatelessWidget {
  const RegisterPasswordRequirementBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.registerPasswordRequirementPillBg,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                AppStrings.passwordHint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.registerPasswordRequirementAccent,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              width: 22.r,
              height: 22.r,
              child: Image.asset(
                AppAssets.authPasswordMet,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
