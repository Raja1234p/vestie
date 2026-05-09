import 'package:flutter/material.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import '../../models/user_vff_profile_ui_model.dart';
import '../user_vff_joined_project_row.dart';
import '../user_vff_rounded_sheet.dart';
import '../user_vff_tx_row.dart';
import 'user_vff_profile_footer_actions.dart';
import 'user_vff_profile_identity_section.dart';
import 'user_vff_profile_metric_strip.dart';

/// Scrollable sheet + sticky footer overlay.
final class UserVffProfileSheetStack extends StatelessWidget {
  final UserVffProfileUiModel profile;

  const UserVffProfileSheetStack({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final showJoined = p.joinedProjects?.isNotEmpty ?? false;
    final showTx = !showJoined && (p.transactions?.isNotEmpty ?? false);

    return UserVffRoundedSheet(
      padding: AppDimens.sheetInsetProfile,
      child: Stack(
        children: [
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: AppDimens.v92),
            children: [
              UserVffProfileIdentitySection(profile: p),
              SizedBox(height: AppDimens.v18),
              UserVffProfileMetricStrip(profile: p),
              SizedBox(height: AppDimens.v20),
              if (showTx)
                ...(p.transactions ?? []).map((r) => UserVffTxRow(row: r)),
              if (showJoined)
                ...(p.joinedProjects ?? [])
                    .map((r) => UserVffJoinedProjectRow(row: r)),
              if (!showJoined && !showTx) SizedBox(height: AppDimens.v20),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: UserVffProfileFooterActions(profile: p),
            ),
          ),
        ],
      ),
    );
  }
}
