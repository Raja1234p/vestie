import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/user/features/vff/presentation/widgets/user_vff_profile_background.dart';

import '../cubit/project_invitation_cubit.dart';
import '../widgets/project_invitation_footer.dart';
import '../widgets/project_invitation_join_listener.dart';
import '../widgets/project_invitation_scroll_area.dart';

/// Shown when a logged-in user opens `vestie.app/join/{inviteCode}`.
///
/// Signed-out users are redirected to login with the invite code kept in
/// [PendingProjectInviteStore] (router guard + splash/deep-link handling).
///
/// Shell matches [AppSuccessScreen]: background + [Column] with scrollable
/// [Expanded] and pinned [FlowScreenFooter].
final class ProjectInvitationScreen extends StatelessWidget {
  final String inviteCode;

  const ProjectInvitationScreen({super.key, required this.inviteCode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectInvitationCubit(inviteCode: inviteCode)..load(),
      child: ProjectInvitationJoinListener(
        child: UserVffProfileBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: const ProjectInvitationScrollArea(),
                    ),
                  ),
                ),
                const ProjectInvitationFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
