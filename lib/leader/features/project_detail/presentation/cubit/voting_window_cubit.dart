import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/utils/validation_utils.dart';
import 'package:vestie/features/project_detail/domain/entities/leader_voting_flow_kind.dart';
import 'package:vestie/features/project_detail/domain/usecases/project_actions_usecases.dart';

part 'voting_window_state.dart';

class VotingWindowCubit extends Cubit<VotingWindowState> {
  static const int maxDigits = 3;

  final String projectId;
  final LeaderVotingFlowKind flowKind;
  final OpenClosureVotingUseCase _openClosureVotingUseCase;
  final OpenStopContributionsVotingUseCase _openStopContributionsVotingUseCase;

  VotingWindowCubit({
    required this.projectId,
    required this.flowKind,
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
        ),
      LeaderVotingFlowKind.stopContributions =>
        await _openStopContributionsVotingUseCase(
          projectId: projectId,
          votingWindowDays: days,
        ),
    };

    return result.fold(
      (failure) {
        emit(state.copyWith(loading: false, apiErrorMessage: failure.message));
        return false;
      },
      (_) {
        emit(state.copyWith(loading: false));
        return true;
      },
    );
  }
}
