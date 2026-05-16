import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/project_detail/presentation/bloc/voting_bloc.dart';
import 'package:vestie/features/project_detail/presentation/bloc/voting_event.dart';
import 'package:vestie/features/project_detail/presentation/bloc/voting_state.dart';
import '../models/member_success_vote_ui_data.dart';
import '../widgets/member_success_vote_content.dart';

/// Member: vote on whether the project was successful (standalone route).
class UserSuccessVoteScreen extends StatelessWidget {
  final UserSuccessVoteArgs args;

  const UserSuccessVoteScreen({super.key, required this.args});

  Future<bool> _submitVote(BuildContext context, bool voteForSuccess) async {
    final projectId = args.projectId;
    if (projectId == null || projectId.isEmpty) return true;

    final bloc = context.read<VotingBloc>();
    bloc.add(SubmitVoteActionEvent(
      projectId: projectId,
      isPositive: voteForSuccess,
    ));

    final next = await bloc.stream.firstWhere(
      (s) => !s.isLoading,
    );
    if (next.failure != null) {
      if (context.mounted) {
        AppSnackBar.showError(context, next.failure!.message);
      }
      return false;
    }
    return next.isSuccess;
  }

  @override
  Widget build(BuildContext context) {
    final data = MemberSuccessVoteUiData.fromArgs(args);

    return BlocProvider(
      create: (_) => ServiceLocator.instance.votingBloc,
      child: BlocBuilder<VotingBloc, VotingState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: PostAuthGradientBackground(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PostAuthHeader(
                    title: args.projectName,
                    leading: AppBackButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.dashboard);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                      child: MemberSuccessVoteContent(
                        data: data,
                        isLoading: state.isLoading,
                        onSubmitVote: (voteForSuccess) =>
                            _submitVote(context, voteForSuccess),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
