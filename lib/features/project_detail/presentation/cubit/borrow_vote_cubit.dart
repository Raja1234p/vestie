import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/user/features/borrow/domain/usecases/vote_borrow_request_use_case.dart';
import 'borrow_vote_state.dart';

/// Manages member Agree/Disagree votes for one borrow request card.
class BorrowVoteCubit extends Cubit<BorrowVoteState> {
  final VoteBorrowRequestUseCase _voteUseCase;
  final String projectId;
  final String requestId;

  BorrowVoteCubit({
    required VoteBorrowRequestUseCase voteUseCase,
    required this.projectId,
    required this.requestId,
    required int upvotes,
    required int downvotes,
    String? callerVote,
  }) : _voteUseCase = voteUseCase,
       super(
         BorrowVoteState(
           upvotes: upvotes,
           downvotes: downvotes,
           hasUpvoted: callerVote == 'Agree',
           hasDownvoted: callerVote == 'Disagree',
         ),
       );

  Future<String?> voteAgree() => _submitVote('Agree');

  Future<String?> voteDisagree() => _submitVote('Disagree');

  Future<String?> _submitVote(String vote) async {
    if (state.isVoting) return null;
    if (vote == 'Agree' && state.hasUpvoted) return null;
    if (vote == 'Disagree' && state.hasDownvoted) return null;

    emit(state.copyWith(isVoting: true));

    final result = await _voteUseCase(
      projectId: projectId,
      borrowRequestId: requestId,
      vote: vote,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isVoting: false));
        return FailureMapper.userMessage(failure);
      },
      (data) {
        emit(
          BorrowVoteState(
            upvotes: data.upvoteCount,
            downvotes: data.downvoteCount,
            hasUpvoted: data.callerVote == 'Agree',
            hasDownvoted: data.callerVote == 'Disagree',
          ),
        );
        return null;
      },
    );
  }
}
