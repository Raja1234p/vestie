import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/notification_favourite_header_actions.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Home fixed header — [AppDimens.homeHeaderHeight] gradient under status bar.
class HomeHeader extends StatelessWidget {
  final double totalContributed;

  const HomeHeader({super.key, required this.totalContributed});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        width: double.infinity,
        height: AppDimens.homeHeaderHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.headerGradient),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            AppStrings.totalContributed,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lato(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.neutral1200,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          AppText(
                            '\$${_formatAmount(totalContributed)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lato(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const NotificationFavouriteHeaderActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatAmount(double v) {
    final parts = v.toStringAsFixed(0).split('');
    final buf = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buf.write(',');
      buf.write(parts[i]);
    }
    return buf.toString();
  }
}
