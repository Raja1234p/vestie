import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/notification_favourite_header_actions.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';

/// Discover tab header — same band height + status-bar treatment as [HomeHeader].
class DiscoverHeader extends StatelessWidget {
  const DiscoverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return PostAuthHeader(
      title: AppStrings.discoverTitle,
      bandHeight: AppDimens.homeHeaderHeight,
      centerTitleInBand: true,
      trailing: const NotificationFavouriteHeaderActions(),
    );
  }
}
