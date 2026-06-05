import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/notification_favourite_header_actions.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';

/// Top bar for the Discover tab.
class DiscoverHeader extends StatelessWidget {
  const DiscoverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return PostAuthHeader(
      title: AppStrings.discoverTitle,
      applyTopSafeArea: false,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      bottomGap: 0,
      trailing: const NotificationFavouriteHeaderActions(),
    );
  }
}
