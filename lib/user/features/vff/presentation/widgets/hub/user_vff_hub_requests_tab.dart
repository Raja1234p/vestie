import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import '../../cubit/user_vff_hub_cubit.dart';
import '../../cubit/user_vff_hub_state.dart';
import '../../models/user_vff_hub_ui_model.dart';
import '../../models/user_vff_profile_ui_model.dart';
import '../user_vff_hub_empty_body.dart';
import '../user_vff_group_invitation_card.dart';
import '../user_vff_incoming_request_card.dart';
import '../user_vff_section_header.dart';

/// Hub “Requests” tab (VFF requests + group previews).
final class UserVffHubRequestsTab extends StatelessWidget {
  final UserVffHubState hubState;

  const UserVffHubRequestsTab({super.key, required this.hubState});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UserVffHubCubit>();
    final inc = hubState.incomingVffRequests;
    final grp = hubState.groupInvitations;

    if (inc.isEmpty && grp.isEmpty) {
      return const UserVffHubEmptyBody(
        message: AppStrings.userVffEmptyRequests,
      );
    }

    final cap = UserVffHubState.previewCap;
    final incPrev = inc.length > cap ? inc.sublist(0, cap) : inc;
    final grpPrev = grp.length > cap ? grp.sublist(0, cap) : grp;

    Widget incomingCard(UserVffIncomingRequestUi r) =>
        UserVffIncomingRequestCard(
          item: r,
          onAccept: () {
            cubit.dismissIncoming(r);
            context.push(
              AppRoutes.userVffInvitesSent,
              extra: UserVffInvitesSentRouteArgs(
                inviteCount: 1,
                projectName: r.viaProjectName,
              ),
            );
          },
          onDecline: () => cubit.dismissIncoming(r),
        );

    Widget groupCard(UserVffGroupInviteUi g) =>
        UserVffGroupInvitationCard(
          item: g,
          onPrimary: () {
            if (g.kind == UserVffGroupInviteKind.memberRequestJoin) {
              cubit.dismissGroup(g);
              context.push(
                AppRoutes.userVffProfile,
                extra: UserVffProfileRouteArgs(
                  profile: UserVffProfileUiModel.demoOliviaFollowing(),
                ),
              );
              return;
            }
            cubit.dismissGroup(g);
            context.push(
              AppRoutes.userVffInvitesSent,
              extra: UserVffInvitesSentRouteArgs(
                inviteCount: 1,
                projectName: g.titleLine,
              ),
            );
          },
          onDecline: () => cubit.dismissGroup(g),
        );

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppDimens.p18,
        0,
        AppDimens.p18,
        AppDimens.v28,
      ),
      children: [
        if (inc.isNotEmpty) ...[
          UserVffSectionHeader(
            title: AppStrings.userVffSectionVffRequests,
            actionLabel: AppStrings.userVffSeeAllRequestsLink,
            onAction: () => context.push(
              AppRoutes.userVffVffRequestsAll,
              extra: [...inc],
            ),
          ),
          ...incPrev.map(incomingCard),
        ],
        if (inc.isNotEmpty && grp.isNotEmpty)
          SizedBox(height: AppDimens.v14),
        if (grp.isNotEmpty) ...[
          UserVffSectionHeader(
            title: AppStrings.userVffSectionGroupInvites,
            actionLabel: AppStrings.userVffSeeAllRequestsLink,
            onAction: () => context.push(
              AppRoutes.userVffGroupInvitesAll,
              extra: [...grp],
            ),
          ),
          ...grpPrev.map(groupCard),
        ],
      ],
    );
  }
}
