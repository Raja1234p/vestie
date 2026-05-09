import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/dashboard/presentation/cubit/nav_cubit.dart';

/// Top bar for the Discover tab.
/// The "←" arrow navigates back to the Home tab (tab 0) via NavCubit —
/// matching the Figma "← Discover" header design.
class DiscoverHeader extends StatelessWidget {
  const DiscoverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return PostAuthHeader(
      title: AppStrings.discoverTitle,
      leading: AppBackButton(
        onPressed: () => context.read<NavCubit>().selectTab(0),
        color: AppColors.textPrimary,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => context.push(AppRoutes.notifications),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: SvgPicture.asset(
                AppAssets.iconNotification,
                width: 24.w,
                height: 24.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () => context.push(AppRoutes.userVffMain),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: AppSvgIcon(
                assetPath: AppAssets.iconHeart,
                size: 24.w,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
