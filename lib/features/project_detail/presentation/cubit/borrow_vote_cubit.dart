import 'package:flutter_bloc/flutter_bloc.dart';
import 'borrow_vote_state.dart';

/// UI-only Cubit managing upvote/downvote toggles for one borrow request card.
/// Each card gets its own instance scoped via BlocProvider.
class BorrowVoteCubit extends Cubit<BorrowVoteState> {
  BorrowVoteCubit({required int upvotes, required int downvotes})
      : super(BorrowVoteState(upvotes: upvotes, downvotes: downvotes));

  void toggleUpvote() {
    if (state.hasUpvoted) {
      // Undo upvote
      emit(state.copyWith(hasUpvoted: false, upvotes: state.upvotes - 1));
    } else {
      // Apply upvote; remove downvote if active
      emit(state.copyWith(
        hasUpvoted: true,
        hasDownvoted: false,
        upvotes: state.upvotes + 1,
        downvotes: state.hasDownvoted ? state.downvotes - 1 : state.downvotes,
      ));
    }
  }

  void toggleDownvote() {
    if (state.hasDownvoted) {
      // Undo downvote
      emit(state.copyWith(hasDownvoted: false, downvotes: state.downvotes - 1));
    } else {
      // Apply downvote; remove upvote if active
      emit(state.copyWith(
        hasDownvoted: true,
        hasUpvoted: false,
        downvotes: state.downvotes + 1,
        upvotes: state.hasUpvoted ? state.upvotes - 1 : state.upvotes,
      ));
    }
  }
}
