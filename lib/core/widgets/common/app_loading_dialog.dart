import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';
import 'app_loader.dart';

/// Non-dismissible modal with [AppLoader] (brand primary). Caller must pop the route.
///
/// Use [body] when you need to wrap the dialog (e.g. [BlocListener] to auto-dismiss).
class AppLoadingDialog {
  AppLoadingDialog._();

  /// Visual root for [show] or for custom `showDialog` + listeners.
  static Widget body({String message = AppStrings.loading}) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 26.w),
      child: PopScope(
        canPop: false,
        child: Container(
          width: 150.w,
          padding: EdgeInsets.fromLTRB(22.w, 28.h, 22.w, 28.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLoader(size: 44.w),
              SizedBox(height: 16.h),
              AppText(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> show(
    BuildContext context, {
    String message = AppStrings.loading,
  }) {
    return showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => body(message: message),
    );
  }
}
