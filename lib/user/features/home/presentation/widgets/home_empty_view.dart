import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/notification_favourite_header_actions.dart';

/// Full-screen empty state (Home or Discover): gradient background, optional CTA.
///
/// **Discover:** On empty Discover, the parent omits [DiscoverHeader]; this view
/// includes notification + favourite and normal top [SafeArea] like Home.
class HomeEmptyView extends StatelessWidget {
  const HomeEmptyView({
    super.key,
    required this.title,
    required this.subtitle,
    this.showCreateProjectButton = false,
    this.onCreateProject,
    this.showNotificationFavouriteRow = true,
    this.applyTopSafeArea = true,
  }) : assert(
          !showCreateProjectButton || onCreateProject != null,
          'onCreateProject is required when showCreateProjectButton is true',
        );

  /// Home tab — default copy + Create project.
  factory HomeEmptyView.forHome({Key? key, required VoidCallback onCreateProject}) {
    return HomeEmptyView(
      key: key,
      title: AppStrings.homeEmptyTitle,
      subtitle: AppStrings.homeEmptySubtitle,
      showCreateProjectButton: true,
      onCreateProject: onCreateProject,
      showNotificationFavouriteRow: true,
      applyTopSafeArea: true,
    );
  }

  /// Discover tab — discover copy, no CTA (parent hides [DiscoverHeader] when empty).
  factory HomeEmptyView.forDiscover({Key? key}) {
    return HomeEmptyView(
      key: key,
      title: AppStrings.discoverEmptyTitle,
      subtitle: AppStrings.discoverEmptySubtitle,
      showCreateProjectButton: false,
      showNotificationFavouriteRow: true,
      applyTopSafeArea: true,
    );
  }

  final String title;
  final String subtitle;
  final bool showCreateProjectButton;
  final VoidCallback? onCreateProject;
  /// When true, shows notification + favourite (required when Discover hides [DiscoverHeader]).
  final bool showNotificationFavouriteRow;
  /// Top [SafeArea] inset (use true when this view is the top of the screen).
  final bool applyTopSafeArea;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.emptyStateBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        top: applyTopSafeArea,
        child: Column(
          children: [
            if (showNotificationFavouriteRow)
              Padding(
                padding: EdgeInsets.only(top: 8.h, right: 20.w),
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: NotificationFavouriteHeaderActions(),
                ),
              ),
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAssets.homeDiscoverEmptyState,
                  width: 220.w,
                  height: 220.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 24.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF140930),
                  ),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF443F63),
                      height: 1.5,
                    ),
                  ),
                ),
                if (showCreateProjectButton) ...[
                  SizedBox(height: 34.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: AppButton(
                      text: AppStrings.btnCreateProject,
                      height: 48.h,
                      onPressed: onCreateProject!,
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
