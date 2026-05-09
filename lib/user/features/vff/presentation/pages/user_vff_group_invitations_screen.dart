import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/user_vff_group_invitation_list_cubit.dart';
import '../models/user_vff_hub_ui_model.dart';
import '../widgets/lists/user_vff_group_invitations_scaffold.dart';

/// **Flow: Hub “See all” Group Invitations** — full-scroll group cards.
final class UserVffGroupInvitationsScreen extends StatelessWidget {
  final List<UserVffGroupInviteUi> rows;

  const UserVffGroupInvitationsScreen({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserVffGroupInvitationListCubit(rows),
      child: const UserVffGroupInvitationsScaffold(),
    );
  }
}
