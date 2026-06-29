import 'package:equatable/equatable.dart';

import 'package:vestie/core/error/failures.dart';
import '../models/success_vote_cast_choice.dart';
import '../models/success_vote_cast_ui_data.dart';

enum SuccessVoteCastLoadStatus { initial, loading, loaded, loadFailed }

class SuccessVoteCastState extends Equatable {
  final SuccessVoteCastLoadStatus loadStatus;
  final SuccessVoteCastUiData? data;
  final SuccessVoteCastChoice choice;
  final bool canVote;
  final bool isSubmitting;
  final String? loadErrorMessage;
  final Failure? submitFailure;

  const SuccessVoteCastState({
    this.loadStatus = SuccessVoteCastLoadStatus.initial,
    this.data,
    this.choice = SuccessVoteCastChoice.pending,
    this.canVote = true,
    this.isSubmitting = false,
    this.loadErrorMessage,
    this.submitFailure,
  });

  bool get isLoading => loadStatus == SuccessVoteCastLoadStatus.loading;

  bool get loadFailed => loadStatus == SuccessVoteCastLoadStatus.loadFailed;

  SuccessVoteCastState copyWith({
    SuccessVoteCastLoadStatus? loadStatus,
    SuccessVoteCastUiData? data,
    SuccessVoteCastChoice? choice,
    bool? canVote,
    bool? isSubmitting,
    String? loadErrorMessage,
    bool clearLoadError = false,
    Failure? submitFailure,
    bool clearSubmitFailure = false,
  }) {
    return SuccessVoteCastState(
      loadStatus: loadStatus ?? this.loadStatus,
      data: data ?? this.data,
      choice: choice ?? this.choice,
      canVote: canVote ?? this.canVote,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      loadErrorMessage: clearLoadError
          ? null
          : (loadErrorMessage ?? this.loadErrorMessage),
      submitFailure: clearSubmitFailure
          ? null
          : (submitFailure ?? this.submitFailure),
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    data,
    choice,
    canVote,
    isSubmitting,
    loadErrorMessage,
    submitFailure,
  ];
}
