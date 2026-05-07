import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/submit_vote_usecase.dart';
import 'voting_event.dart';
import 'voting_state.dart';

class VotingBloc extends Bloc<VotingEvent, VotingState> {
  final SubmitVoteUseCase submitVoteUseCase;

  VotingBloc({required this.submitVoteUseCase}) : super(const VotingState()) {
    on<SubmitVoteActionEvent>(_onSubmitVoteAction);
  }

  Future<void> _onSubmitVoteAction(SubmitVoteActionEvent event, Emitter<VotingState> emit) async {
    if (state.isLoading) return; // double-submit prevention

    emit(state.copyWith(isLoading: true, clearFailure: true));

    final result = await submitVoteUseCase(SubmitVoteParams(
      projectId: event.projectId,
      isPositive: event.isPositive,
    ));

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (_) => emit(state.copyWith(isLoading: false, isSuccess: true)),
    );
  }
}
