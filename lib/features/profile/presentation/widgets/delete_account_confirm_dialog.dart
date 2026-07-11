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
  required Future<bool> Function() onConfirm,
}) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    builder: (dialogContext) => _DeleteAccountConfirmDialog(
      navigatorContext: dialogContext,
      onConfirm: onConfirm,
    ),
  );
}

class _DeleteAccountConfirmDialog extends StatefulWidget {
  final BuildContext navigatorContext;
  final Future<bool> Function() onConfirm;

  const _DeleteAccountConfirmDialog({
    required this.navigatorContext,
    required this.onConfirm,
  });

  @override
  State<_DeleteAccountConfirmDialog> createState() =>
      _DeleteAccountConfirmDialogState();
}

class _DeleteAccountConfirmDialogState extends State<_DeleteAccountConfirmDialog> {
  bool _submitting = false;

  void _closeDialog() {
    if (!widget.navigatorContext.mounted) return;
    Navigator.of(widget.navigatorContext).pop();
  }

  Future<void> _onDeletePressed() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    await widget.onConfirm();
    if (!mounted) return;
    _closeDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Container(
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
              onPressed: _onDeletePressed,
              isLoading: _submitting,
              useGradient: false,
              hasShadow: false,
              color: AppColors.red800,
              borderRadius: AppRadius.r8,
            ),
            SizedBox(height: 12.h),
            AppOutlineNeutralButton(
              label: AppStrings.btnCancel,
              onPressed: _submitting ? () {} : _closeDialog,
              borderRadius: AppRadius.r8,
              borderColor: AppColors.neutral1200,
              labelColor: AppColors.neutral1200,
            ),
          ],
        ),
      ),
    );
  }
}
