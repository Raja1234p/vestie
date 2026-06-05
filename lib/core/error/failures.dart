import 'package:equatable/equatable.dart';

/// Base class for domain-layer failures (handled in UseCases/BLoC)
abstract class Failure extends Equatable {
  final String message;
  final String? title;
  const Failure(this.message, [this.title]);

  @override
  List<Object?> get props => [message, title];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.', super.title]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'A local storage error occurred.', super.title]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Please check your internet connection.', super.title]);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;
  const ValidationFailure([
    super.message = 'Validation failed.',
    super.title,
    this.errors,
  ]);

  @override
  List<Object?> get props => [message, title, errors];
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized', super.title]);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Forbidden', super.title]);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out.', super.title]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred.', super.title]);
}

/// User closed the Google account picker — not an error; UI should stay silent.
class SignInCanceledFailure extends Failure {
  const SignInCanceledFailure() : super('');
}
