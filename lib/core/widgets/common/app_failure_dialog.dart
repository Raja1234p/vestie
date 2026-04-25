/// Centralised failure dialog utility.
///
/// Usage:
///   AppFailureDialog.show(context, message: AppStrings.errorGeneric);
///
/// NEVER call showDialog directly in pages for error display — always use this.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';

class AppFailureDialog {
  AppFailureDialog._();

  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onRetry,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _FailureDialogWidget(
        title: title ?? AppStrings.errorDialogTitle,
        message: message,
        onRetry: onRetry,
      ),
    );
  }
}

class _FailureDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const _FailureDialogWidget({
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 26.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 20.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Error icon ────────────────────────────────────────
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 36.w,
              ),
            ),
            SizedBox(height: 14.h),

            // ── Title ─────────────────────────────────────────────
            AppText(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey1100,
                  ),
            ),
            SizedBox(height: 8.h),

            // ── Message ───────────────────────────────────────────
            AppText(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.grey900,
                    height: 1.5,
                  ),
            ),
            SizedBox(height: 22.h),

            // ── Retry button (optional) ────────────────────────────
            if (onRetry != null) ...[
              _ActionButton(
                label: AppStrings.btnRetry,
                onTap: () {
                  Navigator.of(context).pop();
                  onRetry!();
                },
                bgColor: AppColors.error,
                textColor: AppColors.surface,
              ),
              SizedBox(height: 10.h),
            ],

            // ── Dismiss button ────────────────────────────────────
            _ActionButton(
              label: AppStrings.btnDismiss,
              onTap: () => Navigator.of(context).pop(),
              bgColor: Colors.transparent,
              textColor: AppColors.grey900,
              borderColor: AppColors.grey300,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;

  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.bgColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: borderColor ?? bgColor,
          ),
        ),
        child: Center(
          child: AppText(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
          ),
        ),
      ),
    );
  }
}
