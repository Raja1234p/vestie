import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/post_auth_header.dart';

/// Reusable gradient header for profile sub-screens (← Title).
class ProfileSubHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  const ProfileSubHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return PostAuthHeader(
      title: title,
      leading: GestureDetector(
        onTap: onBack ?? () => context.pop(),
        child: Icon(Icons.arrow_back,
            size: 24.w, color: AppColors.textPrimary),
      ),
      trailing: trailing,
    );
  }
}
