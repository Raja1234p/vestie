import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// Page indicator for Figma light-background onboarding.
/// Active  : wide dark-purple pill.
/// Inactive: short semi-transparent dark-purple pill.
class OnboardingPageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentIndex;

  const OnboardingPageIndicator({
    super.key,
    required this.pageCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (index) {
        final bool isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: isActive ? 28.w : 8.w,
          height: 5.h,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.onboardingIndicatorActive   // #4519A0
                : AppColors.onboardingIndicatorInactive, // 33% primary
            borderRadius: BorderRadius.circular(100.r),
          ),
        );
      }),
    );
  }
}
