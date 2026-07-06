import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:vestie/features/project_detail/domain/usecases/get_active_closure_vote_usecase.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/project_detail/presentation/project_detail_reload_coordinator.dart';

import 'leader_view_success_votes_state.dart';

class LeaderViewSuccessVotesCubit extends Cubit<LeaderViewSuccessVotesState> {
  final LeaderViewSuccessVotesRouteArgs args;
  final ProjectDetailRepository _projectDetailRepository;
  final GetActiveClosureVoteUseCase _getActiveClosureVoteUseCase;

  LeaderViewSuccessVotesCubit({
    required this.args,
    required ProjectDetailRepository projectDetailRepository,
    required GetActiveClosureVoteUseCase getActiveClosureVoteUseCase,
  }) : _projectDetailRepository = projectDetailRepository,
       _getActiveClosureVoteUseCase = getActiveClosureVoteUseCase,
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
    );
  }
}
