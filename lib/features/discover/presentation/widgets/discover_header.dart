import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../../../dashboard/presentation/cubit/nav_cubit.dart';

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
      trailing: GestureDetector(
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
    );
  }
}
