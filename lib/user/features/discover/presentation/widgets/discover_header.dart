import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/notification_favourite_header_actions.dart';
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
      applyTopSafeArea: false,
      leading: AppBackButton(
        onPressed: () => context.read<NavCubit>().selectTab(0),
        color: AppColors.textPrimary,
      ),
      trailing: const NotificationFavouriteHeaderActions(),
    );
  }
}
