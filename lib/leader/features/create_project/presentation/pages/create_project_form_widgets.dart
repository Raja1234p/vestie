import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Shared label widget for create-project form fields.
class CPFieldLabel extends StatelessWidget {
  final String text;
  const CPFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: AppText(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.authLabel,
        ),
      ),
    );
  }
}

/// Horizontal dashed divider used between form sections.
class CPDashedDivider extends StatelessWidget {
  const CPDashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        const dashW = 6.0;
        const gap = 4.0;
        final count = (constraints.maxWidth / (dashW + gap)).floor();
        return Row(
          children: List.generate(
            count,
            (_) => Padding(
              padding: const EdgeInsets.only(right: gap),
              child: Container(
                width: dashW,
                height: 1,
                color: AppColors.cardBorder,
              ),
            ),
          ),
        );
      },
    );
  }
}
