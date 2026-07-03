import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_purple_dashed_line.dart';
import '../../../../core/widgets/common/app_shimmer.dart';
import '../../../../core/widgets/common/flow_screen_footer.dart';

/// Skeleton for [KeyGuidelinesScreen] while `GET /content/user-guidelines` loads.
class UserGuidelinesListShimmer extends StatelessWidget {
  const UserGuidelinesListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: FlowScreenFooterInsets.listPadding(
          context,
          top: AppDimens.v4,
        ),
        itemCount: 5,
        separatorBuilder: (context, index) => const AppPurpleDashedLine(
          color: AppColors.purple300,
          height: 1,
        ),
        itemBuilder: (context, index) => const _UserGuidelineSectionShimmer(),
      ),
    );
  }
}

class _UserGuidelineSectionShimmer extends StatelessWidget {
  const _UserGuidelineSectionShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmer.box(width: 180.w, height: 22.h, borderRadius: 4.r),
          SizedBox(height: 12.h),
          AppShimmer.box(width: double.infinity, height: 14.h, borderRadius: 4.r),
          SizedBox(height: 8.h),
          AppShimmer.box(width: double.infinity, height: 14.h, borderRadius: 4.r),
          SizedBox(height: 8.h),
          AppShimmer.box(width: 240.w, height: 14.h, borderRadius: 4.r),
        ],
      ),
    );
  }
}
