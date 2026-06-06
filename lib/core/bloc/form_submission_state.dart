import 'package:equatable/equatable.dart';

enum FormSubmissionStatus { initial, validating, submitting, success, failure }

class FormSubmissionState extends Equatable {
  final FormSubmissionStatus status;
  final String? errorMessage;
  final Map<String, String>? validationErrors;

  const FormSubmissionState({
    this.status = FormSubmissionStatus.initial,
    this.errorMessage,
    this.validationErrors,
  });

  FormSubmissionState copyWith({
    FormSubmissionStatus? status,
    String? errorMessage,
    Map<String, String>? validationErrors,
    bool clearErrorMessage = false,
    bool clearValidationErrors = false,
  }) {
    return FormSubmissionState(
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      validationErrors: clearValidationErrors
          ? null
          : (validationErrors ?? this.validationErrors),
    );
  }

  bool get isSubmitting => status == FormSubmissionStatus.submitting;
  bool get isSuccess => status == FormSubmissionStatus.success;
  bool get isFailure => status == FormSubmissionStatus.failure;

  @override
  List<Object?> get props => [status, errorMessage, validationErrors];
}
