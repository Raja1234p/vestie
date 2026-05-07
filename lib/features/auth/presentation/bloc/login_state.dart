import '../../../../core/bloc/form_submission_state.dart';
import '../../domain/entities/user.dart';

abstract class LoginState extends FormSubmissionState {
  const LoginState({
    super.status = FormSubmissionStatus.initial,
    super.errorMessage,
    super.validationErrors,
  });
}

class LoginInitial extends LoginState {
  const LoginInitial() : super(status: FormSubmissionStatus.initial);
}

class LoginLoading extends LoginState {
  const LoginLoading() : super(status: FormSubmissionStatus.submitting);
}

class LoginSuccess extends LoginState {
  final User user;
  final bool isDisclaimerAccepted;

  const LoginSuccess({
    required this.user,
    this.isDisclaimerAccepted = false,
  }) : super(status: FormSubmissionStatus.success);

  @override
  List<Object?> get props => [status, errorMessage, validationErrors, user, isDisclaimerAccepted];
}

class LoginError extends LoginState {
  final String message;
  final String? title;

  const LoginError({
    required this.message,
    this.title,
    Map<String, String>? validationErrors,
  }) : super(status: FormSubmissionStatus.failure, errorMessage: message, validationErrors: validationErrors);

  @override
  List<Object?> get props => [status, errorMessage, validationErrors, message, title];
}
