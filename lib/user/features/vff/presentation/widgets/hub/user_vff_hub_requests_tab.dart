import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import '../../cubit/user_vff_hub_cubit.dart';
import '../../cubit/user_vff_hub_state.dart';
import '../../models/user_vff_hub_ui_model.dart';
import '../user_vff_group_invitation_card.dart';
import '../user_vff_hub_empty_body.dart';
import '../user_vff_incoming_request_card.dart';
import '../user_vff_section_header.dart';

/// Hub “Requests” tab — incoming VFF requests + project invitations (single scroll).
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

    final acting = hubState.actingRow;

    Widget incomingCard(UserVffIncomingRequestUi r) =>
        UserVffIncomingRequestCard(
          item: r,
          actingRow: acting,
          onAccept: () => cubit.acceptVffRequest(r),
          onDecline: () => cubit.declineVffRequest(r),
        );

    Widget groupCard(UserVffGroupInviteUi g) => UserVffGroupInvitationCard(
      item: g,
      actingRow: acting,
      onPrimary: () {
        if (g.kind == UserVffGroupInviteKind.memberRequestJoin) {
          return;
        }
        cubit.acceptProjectInvite(g);
      },
      onDecline: () => cubit.declineProjectInvite(g),
    );

    final inboxBusy = acting != null;

    return ListView(
      physics: inboxBusy
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
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
            actionLabel: AppStrings.userVffSeeAllVffRequestsLink,
            onAction: () async {
              await context.push(AppRoutes.userVffVffRequestsAll);
              if (!context.mounted) return;
              final hubCubit = context.read<UserVffHubCubit>();
              await hubCubit.refreshReceivedInboxSilently();
              await hubCubit.refreshMyVffsSilently();
            },
          ),
          ...incPrev.map(incomingCard),
        ],
        if (inc.isNotEmpty && grp.isNotEmpty) SizedBox(height: AppDimens.v14),
        if (grp.isNotEmpty) ...[
          UserVffSectionHeader(
            title: AppStrings.userVffSectionGroupInvites,
            actionLabel: AppStrings.userVffSeeAllGroupInvitesLink,
            onAction: () async {
              await context.push(AppRoutes.userVffGroupInvitesAll);
              if (!context.mounted) return;
              await context
                  .read<UserVffHubCubit>()
                  .refreshReceivedInboxSilently();
            },
          ),
          ...grpPrev.map(groupCard),
        ],
      ],
    );
  }
}
