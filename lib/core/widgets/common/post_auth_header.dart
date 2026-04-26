import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../text/app_text.dart';

/// Reusable title header for post-auth screens on gradient background.
class PostAuthHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;
  final double bottomGap;

  const PostAuthHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.padding,
    this.titleStyle,
    this.bottomGap = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: padding ?? EdgeInsets.fromLTRB(2.w, 20.h, 16.w, 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (leading != null) ...[leading!, SizedBox(width: 8.w)],
                AppText(
                  title,
                  style: titleStyle ??
                      GoogleFonts.lato(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey1100,
                        letterSpacing: -0.5,
                      ),
                ),
                const Spacer(),
                ?trailing,
              ],
            ),
            SizedBox(height: bottomGap.h),
          ],
        ),
      ),
    );
  }
}
