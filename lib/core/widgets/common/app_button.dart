import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

/// Full-width gradient pill button — matches Figma "Continue" button.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.purple700, AppColors.purple900],
                )
              : null,
          color: isEnabled ? null : AppColors.textHint,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isEnabled
                ? AppColors.purple500.withValues(alpha: 0.45)
                : AppColors.grey400,
            width: 1,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.purple900.withValues(alpha: 0.28),
                    blurRadius: 14.r,
                    offset: Offset(0, 4.h),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(999.r),
            onTap: isLoading ? null : onPressed,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22.w,
                      height: 22.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.surface,
                      ),
                    )
                  : Text(
                      text,
                      style: GoogleFonts.lato(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.surface,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
