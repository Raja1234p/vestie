import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_outline_neutral_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';

/// Pinned footer — Mark as Defaulted, then Remove Member (Figma Penalty Action).
class PenaltyActionFooter extends StatelessWidget {
  final bool showRemoveMember;
  final bool showMarkAsDefaulted;
  final VoidCallback onRemoveMember;
  final VoidCallback onMarkDefaulted;

  const PenaltyActionFooter({
    super.key,
    required this.showRemoveMember,
    required this.showMarkAsDefaulted,
    required this.onRemoveMember,
    required this.onMarkDefaulted,
  });

  static const _outlineColor = AppColors.red900;

  @override
  Widget build(BuildContext context) {
    if (!showRemoveMember && !showMarkAsDefaulted) {
      return const SizedBox.shrink();
    }

    return FlowScreenFooter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showMarkAsDefaulted)
            AppOutlineNeutralButton(
              label: AppStrings.markAsDefaulted,
              onPressed: onMarkDefaulted,
              borderRadius: AppRadius.r8,
              borderColor: _outlineColor,
              labelColor: _outlineColor,
            ),
          if (showRemoveMember && showMarkAsDefaulted) SizedBox(height: 12.h),
          if (showRemoveMember)
            AppOutlineNeutralButton(
              label: AppStrings.btnRemoveMember,
              onPressed: onRemoveMember,
              borderRadius: AppRadius.r8,
              backgroundColor: AppColors.red100,
              borderColor: AppColors.red100,
              labelColor: AppColors.red900,
            ),
        ],
      ),
    );
  }
}
