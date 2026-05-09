import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_outline_button_compact.dart';

/// **Flow: Profile (Following) → remove VFF** — destructive confirmation.
Future<bool?> showUserVffRemoveConnectionDialog(
  BuildContext context, {
  required String usernameWithoutAt,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: AppDimens.removeDialogOuterInsets,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r22),
        ),
        child: Padding(
          padding: AppDimens.removeDialogInnerInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppDimens.dialogErrorIconDiameter,
                height: AppDimens.dialogErrorIconDiameter,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error,
                ),
                child: AppSvgIcon(
                  assetPath: AppAssets.iconClose,
                  color: AppColors.surface,
                  size: AppDimens.iconGlyphLg,
                ),
              ),
              SizedBox(height: AppDimens.v16),
              AppText(
                AppStrings.userVffRemoveTitle(usernameWithoutAt),
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w900,
                  fontSize: 18.sp,
                  color: AppColors.grey1100,
                  height: 1.25,
                ),
              ),
              SizedBox(height: AppDimens.v10),
              AppText(
                AppStrings.userVffRemoveBody,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 13.sp,
                  height: 1.45,
                  color: AppColors.textBody,
                ),
              ),
              SizedBox(height: AppDimens.v22),
              Row(
                children: [
                  Expanded(
                    child: UserVffOutlineButtonCompact(
                      label: AppStrings.btnNo,
                      onTap: () => Navigator.of(dialogCtx).pop(false),
                      height: AppDimens.buttonHeightDialogCompact,
                    ),
                  ),
                  SizedBox(width: AppDimens.p12),
                  Expanded(
                    child: AppButton(
                      text: AppStrings.userLeaveConfirmYes,
                      height: AppDimens.buttonHeightDialogCompact,
                      useGradient: false,
                      color: AppColors.error,
                      hasShadow: false,
                      onPressed: () => Navigator.of(dialogCtx).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
