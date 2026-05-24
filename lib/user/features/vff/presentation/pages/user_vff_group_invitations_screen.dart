import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/di/service_locator.dart';

import '../cubit/user_vff_group_invitation_list_cubit.dart';
import '../widgets/lists/user_vff_group_invitations_scaffold.dart';

/// **Flow: Hub “See all” Group Invitations** — full-scroll group cards.
final class UserVffGroupInvitationsScreen extends StatelessWidget {
  const UserVffGroupInvitationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sl = ServiceLocator.instance;
    return BlocProvider(
      create: (_) => UserVffGroupInvitationListCubit(
        getVffReceivedInboxUseCase: sl.getVffReceivedInboxUseCase,
        acceptVffProjectInviteUseCase: sl.acceptVffProjectInviteUseCase,
        declineVffProjectInviteUseCase: sl.declineVffProjectInviteUseCase,
      ),
      child: const UserVffGroupInvitationsScaffold(),
    );
  }
}
