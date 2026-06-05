import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Gradient pill button matching the Figma "Continue" / "Verify" button.
/// Uses a LinearGradient decoration since ElevatedButton doesn't natively support it.
class AuthGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? borderRadius;

  const AuthGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    /// Keep gradient while [isLoading] — gray fill only when truly inactive.
    final bool useActiveStyle = isEnabled || isLoading;
    final radius = BorderRadius.circular(borderRadius ?? 100.r);

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: useActiveStyle
              ? const LinearGradient(
                  colors: [AppColors.authButtonStart, AppColors.authButtonEnd],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: useActiveStyle
              ? null
              : AppColors.authHint.withValues(alpha: 0.3),
          borderRadius: radius,
          boxShadow: useActiveStyle
              ? [
                  BoxShadow(
                    color: AppColors.authButtonEnd.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: isLoading ? null : onPressed,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22.w,
                      height: 22.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      text,
                      style: GoogleFonts.lato(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
