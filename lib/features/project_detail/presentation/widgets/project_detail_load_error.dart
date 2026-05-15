import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/text/app_text.dart';

/// Shown when `GET /projects/{id}` fails — offers retry without leaving the screen.
class ProjectDetailLoadError extends StatelessWidget {
  const ProjectDetailLoadError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textBody,
              ),
            ),
            SizedBox(height: 20.h),
            AppButton(
              text: AppStrings.btnRetry,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
