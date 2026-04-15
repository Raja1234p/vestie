import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// Shared label widget for create-project form fields.
class CPFieldLabel extends StatelessWidget {
  final String text;
  const CPFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textBody,
        ),
      ),
    );
  }
}

/// Shared text field with consistent styling.
/// Pass [errorText] to display an inline red error below the field.
class CPTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;
  final String? errorText;

  const CPTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.suffixIcon,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.searchBarBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.cardBorder,
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            style: GoogleFonts.inter(
                fontSize: 14.sp, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                  fontSize: 14.sp, color: AppColors.authHint),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              errorText!,
              style: GoogleFonts.inter(
                  fontSize: 11.sp, color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

/// Horizontal dashed divider used between form sections.
class CPDashedDivider extends StatelessWidget {
  const CPDashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      const dashW = 6.0;
      const gap   = 4.0;
      final count = (constraints.maxWidth / (dashW + gap)).floor();
      return Row(
        children: List.generate(count, (_) => Padding(
          padding: const EdgeInsets.only(right: gap),
          child: Container(width: dashW, height: 1, color: AppColors.cardBorder),
        )),
      );
    });
  }
}

/// Shared dark pill button used for all wizard step actions
/// (Next, Save Changes, Create Project).
/// Matches Figma pill shape on every step screen.
class CPNextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const CPNextButton({
    super.key,
    required this.onPressed,
    this.label = AppStrings.btnNext,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardActionBtn,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.r)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
