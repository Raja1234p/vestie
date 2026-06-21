import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/post_auth_flow_sub_header.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/features/project_detail/presentation/bloc/voting_bloc.dart';
import 'package:vestie/features/project_detail/presentation/bloc/voting_event.dart';
import 'package:vestie/features/project_detail/presentation/bloc/voting_state.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_ui_data.dart';
import 'package:vestie/features/success_vote/presentation/widgets/success_vote_cast_content.dart';

/// Member / co-leader: cast a vote while a success vote is open.
class SuccessVoteCastScreen extends StatelessWidget {
  final SuccessVoteCastRouteArgs args;

  const SuccessVoteCastScreen({super.key, required this.args});

  Future<bool> _submitVote(BuildContext context, bool voteForSuccess) async {
    final projectId = args.projectId;
    if (projectId == null || projectId.isEmpty) return true;

    final bloc = context.read<VotingBloc>();
    bloc.add(
      SubmitVoteActionEvent(projectId: projectId, isPositive: voteForSuccess),
    );

    final next = await bloc.stream.firstWhere((s) => !s.isLoading);
    if (next.failure != null) {
      if (context.mounted) {
        AppToast.showError(context, next.failure!.message);
      }
      return false;
    }
    return next.isSuccess;
  }

  @override
  Widget build(BuildContext context) {
    final data = SuccessVoteCastUiData.fromArgs(args);

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
                  PostAuthFlowSubHeader(
                    title: args.projectName,
                    onBack: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.dashboard);
                      }
                    },
                  ),
                  Expanded(
                    child: SuccessVoteCastContent(
                      data: data,
                      isLoading: state.isLoading,
                      onSubmitVote: (voteForSuccess) =>
                          _submitVote(context, voteForSuccess),
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

/// @deprecated Use [SuccessVoteCastScreen].
typedef UserSuccessVoteScreen = SuccessVoteCastScreen;
