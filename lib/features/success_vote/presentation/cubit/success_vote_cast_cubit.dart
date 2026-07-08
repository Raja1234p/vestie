import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/usecases/get_active_closure_vote_usecase.dart';
import 'package:vestie/features/project_detail/domain/usecases/submit_vote_usecase.dart';
import 'package:vestie/features/project_detail/presentation/project_detail_reload_coordinator.dart';

import '../models/success_vote_cast_choice.dart';
import '../models/success_vote_cast_route_args.dart';
import '../models/success_vote_cast_ui_data.dart';
import 'success_vote_cast_state.dart';

class SuccessVoteCastCubit extends Cubit<SuccessVoteCastState> {
  final SuccessVoteCastRouteArgs args;
  final GetActiveClosureVoteUseCase _getActiveClosureVoteUseCase;
  final SubmitVoteUseCase _submitVoteUseCase;

  SuccessVoteCastCubit({
    required this.args,
    required GetActiveClosureVoteUseCase getActiveClosureVoteUseCase,
    required SubmitVoteUseCase submitVoteUseCase,
  }) : _getActiveClosureVoteUseCase = getActiveClosureVoteUseCase,
       _submitVoteUseCase = submitVoteUseCase,
       super(const SuccessVoteCastState());

  Future<void> load() async {
    final projectId = args.projectId?.trim();
    if (projectId == null || projectId.isEmpty) {
      emit(
        SuccessVoteCastState(
          loadStatus: SuccessVoteCastLoadStatus.loaded,
          data: SuccessVoteCastUiData.fromArgs(args),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        loadStatus: SuccessVoteCastLoadStatus.loading,
        clearLoadError: true,
      ),
    );

    final result = await _getActiveClosureVoteUseCase(projectId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          loadStatus: SuccessVoteCastLoadStatus.loadFailed,
          loadErrorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (vote) {
        if (vote == null || !vote.isOpen) {
          emit(
            state.copyWith(
              loadStatus: SuccessVoteCastLoadStatus.loadFailed,
              loadErrorMessage: AppStrings.errorClosureVoteNoOpenVote,
            ),
          );
          return;
        }

        emit(
          _loadedFromActiveVote(vote),
        );
      },
    );
  }

  SuccessVoteCastState _loadedFromActiveVote(ActiveClosureVoteEntity vote) {
    final choice = _choiceFromCallerVote(vote.callerVote);
    final canVote = !vote.callerIsGroupLeader && choice == SuccessVoteCastChoice.pending;

    return SuccessVoteCastState(
      loadStatus: SuccessVoteCastLoadStatus.loaded,
      data: SuccessVoteCastUiData.fromActiveVote(vote: vote, args: args),
      choice: choice,
      canVote: canVote,
    );
  }

  static SuccessVoteCastChoice _choiceFromCallerVote(ClosureVoteValue? vote) {
    return switch (vote) {
      ClosureVoteValue.yes => SuccessVoteCastChoice.agreed,
      ClosureVoteValue.no => SuccessVoteCastChoice.disagreed,
      null => SuccessVoteCastChoice.pending,
    };
  }

  Future<bool> submitVote(bool voteForSuccess) async {
    final projectId = args.projectId?.trim();
    if (projectId == null || projectId.isEmpty) return false;
    if (!state.canVote || state.choice != SuccessVoteCastChoice.pending) {
      return false;
    }
    if (state.isSubmitting) return false;

    emit(
      state.copyWith(
        submittingVoteForSuccess: voteForSuccess,
        clearSubmitFailure: true,
      ),
    );

    final result = await _submitVoteUseCase(
      SubmitVoteParams(projectId: projectId, isPositive: voteForSuccess),
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            clearSubmitting: true,
            submitFailure: failure,
          ),
        );
        return false;
      },
      (castResult) async {
        final data = state.data;
        final updatedData = data?.copyWithTallies(
          thumbsUp: castResult.thumbsUp,
          thumbsDown: castResult.thumbsDown,
          notVoted: castResult.notYetVoted,
        );

        emit(
          state.copyWith(
            clearSubmitting: true,
            data: updatedData,
            choice: voteForSuccess
                ? SuccessVoteCastChoice.agreed
                : SuccessVoteCastChoice.disagreed,
            canVote: false,
          ),
        );

        await ProjectDetailReloadCoordinator.reload(projectId);
        return true;
      },
    );
  }
}
