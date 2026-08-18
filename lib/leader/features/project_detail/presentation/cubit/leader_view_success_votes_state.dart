import 'package:equatable/equatable.dart';

import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';

enum LeaderViewSuccessVotesLoadStatus { initial, loading, loaded, loadFailed }

class LeaderViewSuccessVotesState extends Equatable {
  final LeaderViewSuccessVotesLoadStatus loadStatus;
  final LeaderSuccessVoteProgressUiData? data;
  final String? loadErrorMessage;
  final bool cancelling;
  final String? actionErrorMessage;

  const LeaderViewSuccessVotesState({
    this.loadStatus = LeaderViewSuccessVotesLoadStatus.initial,
    this.data,
    this.loadErrorMessage,
    this.cancelling = false,
    this.actionErrorMessage,
  });

  bool get isLoading => loadStatus == LeaderViewSuccessVotesLoadStatus.loading;

  bool get loadFailed =>
      loadStatus == LeaderViewSuccessVotesLoadStatus.loadFailed;

  LeaderViewSuccessVotesState copyWith({
    LeaderViewSuccessVotesLoadStatus? loadStatus,
    LeaderSuccessVoteProgressUiData? data,
    String? loadErrorMessage,
    bool? cancelling,
    String? actionErrorMessage,
    bool clearLoadError = false,
    bool clearActionError = false,
  }) {
    return LeaderViewSuccessVotesState(
      loadStatus: loadStatus ?? this.loadStatus,
      data: data ?? this.data,
      loadErrorMessage: clearLoadError
          ? null
          : (loadErrorMessage ?? this.loadErrorMessage),
      cancelling: cancelling ?? this.cancelling,
      actionErrorMessage: clearActionError
          ? null
          : (actionErrorMessage ?? this.actionErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    data,
    loadErrorMessage,
    cancelling,
    actionErrorMessage,
  ];
}
