import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/usecases/closure_voting_usecases.dart';
import 'package:vestie/features/project_detail/domain/usecases/get_active_closure_vote_usecase.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/project_detail/presentation/project_detail_reload_coordinator.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';

import 'leader_view_success_votes_state.dart';

class LeaderViewSuccessVotesCubit extends Cubit<LeaderViewSuccessVotesState> {
  final LeaderViewSuccessVotesRouteArgs args;
  final GetActiveClosureVoteUseCase _getActiveClosureVoteUseCase;
  final FinalizeClosureVotingUseCase _finalizeClosureVotingUseCase;
  final List<LeaderSuccessVoteMemberRow> _memberRoster;

  LeaderViewSuccessVotesCubit({
    required this.args,
    required GetActiveClosureVoteUseCase getActiveClosureVoteUseCase,
    required FinalizeClosureVotingUseCase finalizeClosureVotingUseCase,
  }) : _getActiveClosureVoteUseCase = getActiveClosureVoteUseCase,
       _finalizeClosureVotingUseCase = finalizeClosureVotingUseCase,
       _memberRoster = args.data.members,
       super(const LeaderViewSuccessVotesState());

  Future<void> load() async {
    final projectId = args.projectId?.trim();
    if (projectId == null || projectId.isEmpty) {
      emit(
        state.copyWith(
          loadStatus: LeaderViewSuccessVotesLoadStatus.loadFailed,
          loadErrorMessage: AppStrings.errorGeneric,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        loadStatus: LeaderViewSuccessVotesLoadStatus.loading,
        clearLoadError: true,
      ),
    );

    final result = await _getActiveClosureVoteUseCase(projectId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          loadStatus: LeaderViewSuccessVotesLoadStatus.loadFailed,
          loadErrorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (vote) {
        if (vote == null || !vote.isOpen) {
          emit(
            state.copyWith(
              loadStatus: LeaderViewSuccessVotesLoadStatus.loadFailed,
              loadErrorMessage: AppStrings.errorClosureVoteNoOpenVote,
            ),
          );
          return;
        }

        emit(_loadedFromActiveVote(vote));
      },
    );
  }

  LeaderViewSuccessVotesState _loadedFromActiveVote(
    ActiveClosureVoteEntity vote,
  ) {
    return LeaderViewSuccessVotesState(
      loadStatus: LeaderViewSuccessVotesLoadStatus.loaded,
      data: leaderSuccessVoteProgressFromActiveVote(
        vote: vote,
        memberRoster: _memberRoster,
      ),
      canFinalize: _canFinalize(vote),
    );
  }

  static bool _canFinalize(ActiveClosureVoteEntity vote) {
    return vote.callerIsGroupLeader &&
        vote.isOpen &&
        vote.remainingDuration == Duration.zero;
  }

  Future<FinalizeClosureVoteResultEntity?> finalizeVote() async {
    final projectId = args.projectId?.trim();
    if (projectId == null || projectId.isEmpty) return null;
    if (!state.canFinalize || state.isFinalizing) return null;

    emit(state.copyWith(isFinalizing: true, clearFinalizeFailure: true));

    final result = await _finalizeClosureVotingUseCase(projectId: projectId);

    return result.fold(
      (failure) {
        emit(state.copyWith(isFinalizing: false, finalizeFailure: failure));
        return null;
      },
      (finalizeResult) async {
        await ProjectDetailReloadCoordinator.reload(projectId);
        emit(state.copyWith(isFinalizing: false, canFinalize: false));
        return finalizeResult;
      },
    );
  }
}
