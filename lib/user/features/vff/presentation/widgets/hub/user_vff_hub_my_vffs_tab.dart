import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/presentation/widgets/list_load_more_footer.dart';
import '../user_vff_hub_empty_body.dart';
import '../user_vff_my_vff_row.dart';
import '../user_vff_section_header.dart';
import '../../cubit/user_vff_hub_cubit.dart';
import '../../cubit/user_vff_hub_state.dart';
import '../../models/user_vff_hub_ui_model.dart';

/// Hub “My VFFs” tab — connected VFFs, then outgoing “Request Sent” rows.
final class UserVffHubMyVffsTab extends StatefulWidget {
  final UserVffHubState hubState;

  const UserVffHubMyVffsTab({super.key, required this.hubState});

  @override
  State<UserVffHubMyVffsTab> createState() => _UserVffHubMyVffsTabState();
}

class _UserVffHubMyVffsTabState extends State<UserVffHubMyVffsTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    if (max - offset <= 200) {
      context.read<UserVffHubCubit>().loadMoreMyVffs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hubState = widget.hubState;
    final all = hubState.myVffConnections;
    final connected = all
        .where((row) => !row.isPendingSent)
        .toList(growable: false);
    final sentOutgoing = all
        .where((row) => row.isPendingSent)
        .toList(growable: false);

    if (connected.isEmpty && sentOutgoing.isEmpty) {
      return const UserVffHubEmptyBody(message: AppStrings.userVffEmptyMyVffs);
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

    final children = <Widget>[
      if (connected.isNotEmpty) ...[
        const UserVffSectionHeader(title: AppStrings.userVffSectionMyVffs),
        ...connected.map(
          (row) => UserVffMyVffRow(row: row, onOpen: () => openProfile(row)),
        ),
      ],
      if (sentOutgoing.isNotEmpty)
        ...sentOutgoing.map((row) => UserVffMyVffRow(row: row)),
      ListLoadMoreFooter(loadingMore: hubState.myVffsLoadingMore),
    ];

    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppDimens.p18,
        0,
        AppDimens.p18,
        AppDimens.v28,
      ),
      children: children,
    );
  }
}
