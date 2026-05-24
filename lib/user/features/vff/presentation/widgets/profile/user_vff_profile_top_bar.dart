import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Back control + peer display name (Figma VFF profile app bar).
final class UserVffProfileTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const UserVffProfileTopBar({
    super.key,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.p16,
        AppDimens.v8,
        AppDimens.p16,
        AppDimens.v8,
      ),
      child: Row(
        children: [
          AppBackButton(
            onPressed: onBack,
            color: AppColors.guidelineTitle,
          ),
          SizedBox(width: AppDimens.p8),
          Expanded(
            child: AppText(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(
                fontSize: 25.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.guidelineTitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
