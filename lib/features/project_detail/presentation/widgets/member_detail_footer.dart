import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_outline_neutral_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';

/// Pinned footer — Remove Member only on [MemberDetailScreen].
class MemberDetailRemoveMemberFooter extends StatelessWidget {
  final VoidCallback onRemoveMember;

  const MemberDetailRemoveMemberFooter({
    super.key,
    required this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    return FlowScreenFooter(
      child: AppOutlineNeutralButton(
        label: AppStrings.btnRemoveMember,
        onPressed: onRemoveMember,
        borderRadius: AppRadius.r8,
        borderColor: AppColors.red900,
        labelColor: AppColors.red900,
      ),
    );
  }
}
