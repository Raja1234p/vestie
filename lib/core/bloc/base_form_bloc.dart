import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'form_submission_state.dart';
import '../error/failures.dart';

abstract class BaseFormBloc<Event, TState extends FormSubmissionState> extends Bloc<Event, TState> {
  BaseFormBloc(super.initialState);

  /// Helper to safely execute a repository call and map it to the generic FormSubmissionState
  Future<void> executeSubmission<R>(
    Future<Either<Failure, R>> Function() action,
    Emitter<TState> emit, {
    required TState Function(
      FormSubmissionStatus status,
      String? errorMessage,
      String? errorTitle,
      Map<String, String>? errors,
      R? data,
    ) stateBuilder,
  }) async {
    if (state.status == FormSubmissionStatus.submitting) return;

    emit(stateBuilder(FormSubmissionStatus.submitting, null, null, null, null));

    final result = await action();

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          final flatErrors = failure.errors?.map((k, v) => MapEntry(k, v.join(', ')));
          emit(stateBuilder(
            FormSubmissionStatus.failure,
            failure.message,
            failure.title,
            flatErrors,
            null,
          ));
        } else {
          emit(stateBuilder(
            FormSubmissionStatus.failure,
            failure.message,
            failure.title,
            null,
            null,
          ));
        }
      },
      (data) => emit(stateBuilder(FormSubmissionStatus.success, null, null, null, data)),
    );
  }
}
