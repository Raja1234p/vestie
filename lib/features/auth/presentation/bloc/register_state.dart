import '../../../../core/bloc/form_submission_state.dart';
import '../../domain/entities/user.dart';

abstract class RegisterState extends FormSubmissionState {
  const RegisterState({
    super.status = FormSubmissionStatus.initial,
    super.errorMessage,
    super.validationErrors,
  });
}

class RegisterInitial extends RegisterState {
  const RegisterInitial() : super(status: FormSubmissionStatus.initial);
}

/// Email/password register submit only (Continue button loader).
class RegisterLoading extends RegisterState {
  const RegisterLoading() : super(status: FormSubmissionStatus.submitting);
}

/// Google sign-up in progress ([AppLoadingDialog] on register screen).
class RegisterGoogleLoading extends RegisterState {
  const RegisterGoogleLoading() : super(status: FormSubmissionStatus.submitting);
}

class RegisterSuccess extends RegisterState {
  final User user;

  const RegisterSuccess({required this.user}) : super(status: FormSubmissionStatus.success);

  @override
  List<Object?> get props => [status, errorMessage, validationErrors, user];
}

class RegisterError extends RegisterState {
  final String message;
  final String? title;

  const RegisterError({
    required this.message,
    this.title,
    super.validationErrors,
  }) : super(status: FormSubmissionStatus.failure, errorMessage: message);

  @override
  List<Object?> get props => [status, errorMessage, validationErrors, message, title];
}

class RegisterGoogleSuccess extends RegisterState {
  final bool isDisclaimerAccepted;

  const RegisterGoogleSuccess({required this.isDisclaimerAccepted})
      : super(status: FormSubmissionStatus.success);

  @override
  List<Object?> get props => [status, errorMessage, validationErrors, isDisclaimerAccepted];
}
