import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// First step of leave flow — “Stay Here” (green) vs “Yes” (outline).
Future<bool> showUserLeaveProjectDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: AppText(
          AppStrings.userLeaveProjectDialogTitle,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText(
              AppStrings.userLeaveProjectDialogBody,
              style: GoogleFonts.lato(
                fontSize: 13.sp,
                height: 1.4,
                color: AppColors.textBody,
              ),
            ),
            SizedBox(height: 18.h),
            AppButton(
              text: AppStrings.userLeaveStayHere,
              onPressed: () => Navigator.of(dialogContext).pop(false),
              useGradient: false,
              color: AppColors.green700,
              hasShadow: true,
            ),
            SizedBox(height: 12.h),
            AppButton(
              text: AppStrings.userLeaveConfirmYes,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              isSecondary: true,
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}
