import 'package:equatable/equatable.dart';

import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';

enum LeaderViewSuccessVotesLoadStatus { initial, loading, loaded, loadFailed }

class LeaderViewSuccessVotesState extends Equatable {
  final LeaderViewSuccessVotesLoadStatus loadStatus;
  final LeaderSuccessVoteProgressUiData? data;
  final String? loadErrorMessage;

  const LeaderViewSuccessVotesState({
    this.loadStatus = LeaderViewSuccessVotesLoadStatus.initial,
    this.data,
    this.loadErrorMessage,
  });

  bool get isLoading => loadStatus == LeaderViewSuccessVotesLoadStatus.loading;

  bool get loadFailed =>
      loadStatus == LeaderViewSuccessVotesLoadStatus.loadFailed;

  LeaderViewSuccessVotesState copyWith({
    LeaderViewSuccessVotesLoadStatus? loadStatus,
    LeaderSuccessVoteProgressUiData? data,
    String? loadErrorMessage,
    bool clearLoadError = false,
  }) {
    return LeaderViewSuccessVotesState(
      loadStatus: loadStatus ?? this.loadStatus,
      data: data ?? this.data,
      loadErrorMessage: clearLoadError
          ? null
          : (loadErrorMessage ?? this.loadErrorMessage),
    );
  }

  @override
  List<Object?> get props => [loadStatus, data, loadErrorMessage];
}
