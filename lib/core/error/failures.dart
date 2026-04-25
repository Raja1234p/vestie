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
