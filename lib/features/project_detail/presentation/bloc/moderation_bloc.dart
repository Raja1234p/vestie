import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/moderate_member_usecase.dart';
import 'moderation_event.dart';
import 'moderation_state.dart';

class ModerationBloc extends Bloc<ModerationEvent, ModerationState> {
  final ModerateMemberUseCase moderateMemberUseCase;

  ModerationBloc({required this.moderateMemberUseCase}) : super(const ModerationState()) {
    on<SubmitModerationActionEvent>(_onSubmitAction);
  }

  Future<void> _onSubmitAction(SubmitModerationActionEvent event, Emitter<ModerationState> emit) async {
    if (state.isLoading) return; // Prevent double submit

    emit(state.copyWith(isLoading: true, clearFailure: true));

    final result = await moderateMemberUseCase(ModerateMemberParams(
      projectId: event.projectId,
      userId: event.userId,
      action: event.action,
    ));

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (_) => emit(state.copyWith(isLoading: false, isSuccess: true)),
    );
  }
}
