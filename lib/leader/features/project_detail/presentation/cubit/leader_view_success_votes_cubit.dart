import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';
import 'package:vestie/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:vestie/features/project_detail/domain/usecases/closure_voting_usecases.dart';
import 'package:vestie/features/project_detail/domain/usecases/get_active_closure_vote_usecase.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/project_detail/presentation/project_detail_reload_coordinator.dart';

import 'leader_view_success_votes_state.dart';

class LeaderViewSuccessVotesCubit extends Cubit<LeaderViewSuccessVotesState> {
  final LeaderViewSuccessVotesRouteArgs args;
  final ProjectDetailRepository _projectDetailRepository;
  final GetActiveClosureVoteUseCase _getActiveClosureVoteUseCase;
  final FinalizeClosureVotingUseCase _finalizeClosureVotingUseCase;

  LeaderViewSuccessVotesCubit({
    required this.args,
    required ProjectDetailRepository projectDetailRepository,
    required GetActiveClosureVoteUseCase getActiveClosureVoteUseCase,
    required FinalizeClosureVotingUseCase finalizeClosureVotingUseCase,
  }) : _projectDetailRepository = projectDetailRepository,
       _getActiveClosureVoteUseCase = getActiveClosureVoteUseCase,
       _finalizeClosureVotingUseCase = finalizeClosureVotingUseCase,
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

    final detailResult = await _projectDetailRepository.getProjectDetail(
      projectId: projectId,
    );

    await detailResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            loadStatus: LeaderViewSuccessVotesLoadStatus.loadFailed,
            loadErrorMessage: FailureMapper.userMessage(failure),
          ),
        );
      },
      (project) async {
        ProjectDetailReloadCoordinator.mergeVotingSnapshot(projectId, project);

        if (project.votingIsInProgress && project.voting != null) {
          emit(_loadedFromProjectVoting(project));
          return;
        }

        await _loadFromActiveVote(projectId, project: project);
      },
    );
  }

  Future<void> _loadFromActiveVote(
    String projectId, {
    ProjectDetailEntity? project,
  }) async {
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

        emit(_loadedFromActiveVote(vote, project: project));
      },
    );
  }

  LeaderViewSuccessVotesState _loadedFromProjectVoting(
    ProjectDetailEntity project,
  ) {
    final voting = project.voting!;
    return LeaderViewSuccessVotesState(
      loadStatus: LeaderViewSuccessVotesLoadStatus.loaded,
      data: leaderSuccessVoteProgressFromProjectVoting(
        project: project,
        voting: voting,
      ),
      canFinalize: _canFinalizeFromProject(project, voting),
    );
  }

  LeaderViewSuccessVotesState _loadedFromActiveVote(
    ActiveClosureVoteEntity vote, {
    ProjectDetailEntity? project,
  }) {
    return LeaderViewSuccessVotesState(
      loadStatus: LeaderViewSuccessVotesLoadStatus.loaded,
      data: leaderSuccessVoteProgressFromActiveVote(
        vote: vote,
        project: project ?? args.project,
      ),
      canFinalize: _canFinalize(vote),
    );
  }

  static bool _canFinalizeFromProject(
    ProjectDetailEntity project,
    ProjectVotingSummaryEntity voting,
  ) {
    if (project.canFinalizeVotingOnDetail) return true;

    // Defensive: deadline passed but backend still returns votingStatus pending.
    if (!project.isDetailLeader || voting.isFinalized) return false;
    if (project.votingStatus != ProjectVotingStatus.pending) return false;
    final remaining = voting.deadlineAtUtc.difference(DateTime.now().toUtc());
    return remaining.isNegative || remaining == Duration.zero;
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
