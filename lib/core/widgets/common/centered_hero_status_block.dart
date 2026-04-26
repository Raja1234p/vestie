import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../text/app_text.dart';

/// Centered [Image.asset] + headline + body, vertically centered in free space
/// with [SingleChildScrollView] when content is taller than the viewport.
/// No domain or route imports — for approved / not-approved / join result flows.
class CenteredHeroStatusBlock extends StatelessWidget {
  final String imageAsset;
  final String headline;
  final String body;
  final double imageHeight;

  const CenteredHeroStatusBlock({
    super.key,
    required this.imageAsset,
    required this.headline,
    required this.body,
    this.imageHeight = 160,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    imageAsset,
                    height: imageHeight.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 24.h),
                  AppText(
                    headline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey1100,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AppText(
                    body,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16.sp,
                      height: 1.5,
                      color: AppColors.grey800,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
