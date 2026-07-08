import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/core/widgets/common/app_loader.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/features/success_vote/presentation/cubit/success_vote_cast_cubit.dart';
import 'package:vestie/features/success_vote/presentation/cubit/success_vote_cast_state.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_ui_data.dart';
import 'package:vestie/features/success_vote/presentation/widgets/success_vote_cast_content.dart';
import 'package:vestie/features/success_vote/presentation/widgets/success_vote_cast_shell.dart';

/// Member / co-leader: cast a vote while a closure vote is open.
class SuccessVoteCastScreen extends StatelessWidget {
  final SuccessVoteCastRouteArgs args;

  const SuccessVoteCastScreen({super.key, required this.args});

  bool get _usesApiLoad =>
      !args.isPreview &&
      args.projectId != null &&
      args.projectId!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_usesApiLoad) {
      return SuccessVoteCastShell(
        title: args.projectName,
        child: SuccessVoteCastContent(
          data: SuccessVoteCastUiData.fromArgs(args),
        ),
      );
    }

    return BlocProvider(
      create: (_) => ServiceLocator.instance.createSuccessVoteCastCubit(args)
        ..load(),
      child: _SuccessVoteCastProductionBody(args: args),
    );
  }
}

class _SuccessVoteCastProductionBody extends StatelessWidget {
  final SuccessVoteCastRouteArgs args;

  const _SuccessVoteCastProductionBody({required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SuccessVoteCastCubit, SuccessVoteCastState>(
      listenWhen: (prev, curr) => prev.submitFailure != curr.submitFailure,
      listener: (context, state) {
        final failure = state.submitFailure;
        if (failure != null) {
          AppToast.showError(context, FailureMapper.userMessage(failure));
        }
      },
      builder: (context, state) {
        return SuccessVoteCastShell(
          title: args.projectName,
          child: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SuccessVoteCastState state) {
    if (state.isLoading) {
      return const Center(child: AppLoader());
    }

    if (state.loadFailed) {
      return AppErrorView(
        message: state.loadErrorMessage ?? AppStrings.errorGeneric,
        onRetry: () => context.read<SuccessVoteCastCubit>().load(),
      );
    }

    final data = state.data;
    if (data == null) {
      return AppErrorView(
        message: AppStrings.errorGeneric,
        onRetry: () => context.read<SuccessVoteCastCubit>().load(),
      );
    }

    return SuccessVoteCastContent(
      data: data,
      choice: state.choice,
      canVote: state.canVote,
      isLoading: state.isSubmitting,
      onSubmitVote: (voteForSuccess) =>
          context.read<SuccessVoteCastCubit>().submitVote(voteForSuccess),
    );
  }
}

/// @deprecated Use [SuccessVoteCastScreen].
typedef UserSuccessVoteScreen = SuccessVoteCastScreen;
