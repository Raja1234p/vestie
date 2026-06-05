import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_outline_neutral_button.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Delete Account confirmation — Figma destructive dialog.
Future<void> showDeleteAccountConfirmDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
      child: _DeleteAccountConfirmDialog(onConfirm: onConfirm),
    ),
  );
}

class _DeleteAccountConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const _DeleteAccountConfirmDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 24.h, 18.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.grey300, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.statusCancelWarning,
            fit: BoxFit.contain,
            height: 160.h,
          ),
          SizedBox(height: 20.h),
          AppText(
            AppStrings.deleteAccountConfirmBody,
            textAlign: TextAlign.center,
            color: AppColors.profileDeleteAccountLabel,
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          SizedBox(height: 24.h),
          AppButton(
            text: AppStrings.btnDeleteMyAccount,
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            useGradient: false,
            hasShadow: false,
            color: AppColors.red800,
            borderRadius: AppRadius.r8,
          ),
          SizedBox(height: 12.h),
          AppOutlineNeutralButton(
            label: AppStrings.btnCancel,
            onPressed: () => Navigator.of(context).pop(),
            borderRadius: AppRadius.r8,
            borderColor: AppColors.neutral1200,
            labelColor: AppColors.neutral1200,
          ),
        ],
      ),
    );
  }
}
