import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import '../../models/user_vff_profile_lookup.dart';
import '../user_vff_hub_empty_body.dart';
import '../user_vff_my_vff_row.dart';
import '../user_vff_section_header.dart';
import '../../cubit/user_vff_hub_state.dart';

/// Hub “My VFFs” tab body (connections list or empty illustration).
final class UserVffHubMyVffsTab extends StatelessWidget {
  final UserVffHubState hubState;

  const UserVffHubMyVffsTab({super.key, required this.hubState});

  @override
  Widget build(BuildContext context) {
    final my = hubState.myVffConnections;

    if (my.isEmpty) {
      return const UserVffHubEmptyBody(
        message: AppStrings.userVffEmptyMyVffs,
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppDimens.p18,
        0,
        AppDimens.p18,
        AppDimens.v28,
      ),
      children: [
        UserVffSectionHeader(title: AppStrings.userVffSectionMyVffs),
        ...my.map(
          (row) => UserVffMyVffRow(
            row: row,
            onOpen: row.isPendingSent
                ? null
                : () {
              context.push(
                AppRoutes.userVffProfile,
                extra: UserVffProfileRouteArgs(
                  profile: lookupUserVffProfileForConnection(
                    row.id,
                    outboundRequestPending: row.isPendingSent,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
