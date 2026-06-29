import 'package:equatable/equatable.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';

enum LeaderViewSuccessVotesLoadStatus { initial, loading, loaded, loadFailed }

class LeaderViewSuccessVotesState extends Equatable {
  final LeaderViewSuccessVotesLoadStatus loadStatus;
  final LeaderSuccessVoteProgressUiData? data;
  final bool canFinalize;
  final bool isFinalizing;
  final String? loadErrorMessage;
  final Failure? finalizeFailure;

  const LeaderViewSuccessVotesState({
    this.loadStatus = LeaderViewSuccessVotesLoadStatus.initial,
    this.data,
    this.canFinalize = false,
    this.isFinalizing = false,
    this.loadErrorMessage,
    this.finalizeFailure,
  });

  bool get isLoading => loadStatus == LeaderViewSuccessVotesLoadStatus.loading;

  bool get loadFailed =>
      loadStatus == LeaderViewSuccessVotesLoadStatus.loadFailed;

  LeaderViewSuccessVotesState copyWith({
    LeaderViewSuccessVotesLoadStatus? loadStatus,
    LeaderSuccessVoteProgressUiData? data,
    bool? canFinalize,
    bool? isFinalizing,
    String? loadErrorMessage,
    bool clearLoadError = false,
    Failure? finalizeFailure,
    bool clearFinalizeFailure = false,
  }) {
    return LeaderViewSuccessVotesState(
      loadStatus: loadStatus ?? this.loadStatus,
      data: data ?? this.data,
      canFinalize: canFinalize ?? this.canFinalize,
      isFinalizing: isFinalizing ?? this.isFinalizing,
      loadErrorMessage: clearLoadError
          ? null
          : (loadErrorMessage ?? this.loadErrorMessage),
      finalizeFailure: clearFinalizeFailure
          ? null
          : (finalizeFailure ?? this.finalizeFailure),
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    data,
    canFinalize,
    isFinalizing,
    loadErrorMessage,
    finalizeFailure,
  ];
}
