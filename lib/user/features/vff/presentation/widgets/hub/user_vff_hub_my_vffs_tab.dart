import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import '../user_vff_hub_empty_body.dart';
import '../user_vff_my_vff_row.dart';
import '../user_vff_section_header.dart';
import '../../cubit/user_vff_hub_cubit.dart';
import '../../cubit/user_vff_hub_state.dart';
import '../../models/user_vff_hub_ui_model.dart';

/// Hub “My VFFs” tab — connected VFFs, then outgoing “Request Sent” rows.
final class UserVffHubMyVffsTab extends StatelessWidget {
  final UserVffHubState hubState;

  const UserVffHubMyVffsTab({super.key, required this.hubState});

  @override
  Widget build(BuildContext context) {
    final all = hubState.myVffConnections;
    final connected =
        all.where((row) => !row.isPendingSent).toList(growable: false);
    final sentOutgoing =
        all.where((row) => row.isPendingSent).toList(growable: false);

    if (connected.isEmpty && sentOutgoing.isEmpty) {
      return const UserVffHubEmptyBody(
        message: AppStrings.userVffEmptyMyVffs,
      );
    }

    Future<void> openProfile(UserVffConnectionRowUi row) async {
      final result = await context.push<UserVffProfilePopResult?>(
        AppRoutes.userVffProfile,
        extra: UserVffProfileRouteArgs(
          userId: row.id,
          isConnectedProfile: true,
        ),
      );
      if (!context.mounted) return;
      if (result == UserVffProfilePopResult.connectionRemoved) {
        await context.read<UserVffHubCubit>().refreshMyVffsSilently();
      }
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
        if (connected.isNotEmpty) ...[
          const UserVffSectionHeader(title: AppStrings.userVffSectionMyVffs),
          ...connected.map(
            (row) => UserVffMyVffRow(
              row: row,
              onOpen: () => openProfile(row),
            ),
          ),
        ],
        if (connected.isNotEmpty && sentOutgoing.isNotEmpty)
          SizedBox(height: AppDimens.v14),
        if (sentOutgoing.isNotEmpty) ...[
          const UserVffSectionHeader(
            title: AppStrings.userVffSectionSentVffRequests,
          ),
          ...sentOutgoing.map(
            (row) => UserVffMyVffRow(row: row),
          ),
        ],
      ],
    );
  }
}
