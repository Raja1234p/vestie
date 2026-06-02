import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../error/failure_mapper.dart';
import '../../error/failures.dart';
import '../../theme/app_colors.dart';

/// Top toasts via [fluttertoast] — API errors and OTP success (Figma).
class AppToast {
  AppToast._();

  static const Duration _duration = Duration(seconds: 3);

  static void showError(BuildContext context, String message) {
    _show(context, message: message, backgroundColor: AppColors.error);
  }

  /// Success toast — OTP verify resend, edit profile save, etc.
  static void showSuccess(BuildContext context, String message) {
    _show(context, message: message, backgroundColor: AppColors.green700);
  }

  /// Neutral hint (e.g. action blocked until setup is complete).
  static void showInfo(BuildContext context, String message) {
    _show(context, message: message, backgroundColor: AppColors.grey900);
  }

  static void showApiFailure(BuildContext context, Failure failure) {
    showError(context, FailureMapper.userMessage(failure));
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
  }) {
    final text = message.trim();
    if (text.isEmpty || !context.mounted) return;

    final fToast = FToast()..init(context);
    fToast.removeCustomToast();

    fToast.showToast(
      child: _ToastBody(
        message: text,
        backgroundColor: backgroundColor,
      ),
      gravity: ToastGravity.TOP,
      toastDuration: _duration,
      positionedToastBuilder: (ctx, child, gravity) {
        final top = MediaQuery.paddingOf(ctx).top + 8.h;
        return Positioned(
          top: top,
          left: 16.w,
          right: 16.w,
          child: child,
        );
      },
    );
  }
}

class _ToastBody extends StatelessWidget {
  final String message;
  final Color backgroundColor;

  const _ToastBody({
    required this.message,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral100,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}
