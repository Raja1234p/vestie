import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import '../../models/user_vff_profile_ui_model.dart';
import '../user_vff_rounded_sheet.dart';
import '../user_vff_tx_row.dart';
import 'user_vff_profile_connected_body.dart';
import 'user_vff_profile_footer_actions.dart';
import 'user_vff_profile_identity_section.dart';
import 'user_vff_profile_metric_strip.dart';

/// Scrollable sheet + sticky footer overlay.
final class UserVffProfileSheetStack extends StatelessWidget {
  final UserVffProfileUiModel profile;

  const UserVffProfileSheetStack({super.key, required this.profile});

  bool get _isConnectedPeer =>
      profile.badgeMode == UserVffProfileBadgeMode.vffVerified &&
      profile.footerMode == UserVffProfileFooterMode.followingSheet;

  @override
  Widget build(BuildContext context) {
    if (_isConnectedPeer) {
      return UserVffProfileConnectedBody(profile: profile);
    }

    final p = profile;
    final showTx = p.transactions?.isNotEmpty ?? false;

    return Padding(
      padding: EdgeInsets.only(top: AppDimens.v48),
      child: UserVffRoundedSheet(
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
              if (!showTx) SizedBox(height: AppDimens.v20),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimens.p18,
                  0,
                  AppDimens.p18,
                  8.h,
                ),
                child: const UserVffProfileFooterActions(),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
