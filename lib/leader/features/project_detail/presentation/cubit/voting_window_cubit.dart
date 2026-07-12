import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/utils/validation_utils.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/leader_voting_flow_kind.dart';
import 'package:vestie/features/project_detail/domain/usecases/closure_voting_usecases.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

part 'voting_window_state.dart';

class VotingWindowCubit extends Cubit<VotingWindowState> {
  static const int maxDigits = 3;

  final String projectId;
  final LeaderVotingFlowKind flowKind;
  final ProjectCategory projectCategory;
  final OpenClosureVotingUseCase _openClosureVotingUseCase;
  final OpenStopContributionsVotingUseCase _openStopContributionsVotingUseCase;

  VotingWindowCubit({
    required this.projectId,
    required this.flowKind,
    required this.projectCategory,
    OpenClosureVotingUseCase? openClosureVotingUseCase,
    OpenStopContributionsVotingUseCase? openStopContributionsVotingUseCase,
  }) : _openClosureVotingUseCase =
           openClosureVotingUseCase ??
           ServiceLocator.instance.openClosureVotingUseCase,
       _openStopContributionsVotingUseCase =
           openStopContributionsVotingUseCase ??
           ServiceLocator.instance.openStopContributionsVotingUseCase,
       super(const VotingWindowState());

  void setDigitsFromField(String value) {
    if (state.loading) return;
    final filtered = value.replaceAll(RegExp(r'[^0-9]'), '');
    final trimmed = filtered.length > maxDigits
        ? filtered.substring(0, maxDigits)
        : filtered;
    emit(
      state.copyWith(
        digits: trimmed,
        clearErrorText: true,
        clearApiErrorMessage: true,
      ),
    );
  }

  Future<bool> submit() async {
    if (state.loading) return false;

    final error = ValidationUtils.validateVotingWindowDays(state.digits);
    if (error != null) {
      emit(state.copyWith(errorText: error));
      return false;
    }

    emit(
      state.copyWith(
        loading: true,
        clearErrorText: true,
        clearApiErrorMessage: true,
      ),
    );
    final days = int.parse(state.digits);
    final result = switch (flowKind) {
      LeaderVotingFlowKind.markProjectSuccessful =>
        await _openClosureVotingUseCase(
          projectId: projectId,
          votingWindowDays: days,
          voteType: resolveClosureVoteType(
            flowKind: flowKind,
            category: projectCategory,
          ),
        ),
      LeaderVotingFlowKind.stopContributions =>
        await _openStopContributionsVotingUseCase(
          projectId: projectId,
          votingWindowDays: days,
        ),
    };

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            loading: false,
            apiErrorMessage: FailureMapper.userMessage(failure),
          ),
        );
        return false;
      },
      (_) => true,
    );
  }
}
