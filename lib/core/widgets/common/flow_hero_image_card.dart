import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../text/app_text.dart';

/// Reusable hero for flows (success, destructive, info): image + optional caption in a tint card.
class FlowHeroImageCard extends StatelessWidget {
  final String imageAsset;
  final Color backgroundColor;
  final String? caption;
  final Color? captionColor;
  final double imageHeight;
  final EdgeInsetsGeometry? padding;
  final TextStyle? captionStyle;
  final FontWeight captionFontWeight;

  const FlowHeroImageCard({
    super.key,
    required this.imageAsset,
    required this.backgroundColor,
    this.caption,
    this.captionColor,
    this.imageHeight = 200,
    this.padding,
    this.captionStyle,
    this.captionFontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding:
          padding ?? EdgeInsets.fromLTRB(12.w, 20.h, 12.w, 20.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Image.asset(
            imageAsset,
            fit: BoxFit.contain,
            height: imageHeight.h,
          ),
          if (caption != null && caption!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            AppText(
              caption!,
              textAlign: TextAlign.center,
              style: captionStyle ??
                  theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: captionFontWeight,
                    color: captionColor,
                    height: 1.3,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
