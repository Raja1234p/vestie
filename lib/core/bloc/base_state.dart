import 'package:equatable/equatable.dart';

abstract class BaseState<T> extends Equatable {
  const BaseState();
  @override
  List<Object?> get props => [];
}

class BaseInitial<T> extends BaseState<T> {}

class BaseLoading<T> extends BaseState<T> {}

class BaseSuccess<T> extends BaseState<T> {
  final T data;
  const BaseSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class BaseFailure<T> extends BaseState<T> {
  final String message;
  final String? title;

  const BaseFailure({required this.message, this.title});

  @override
  List<Object?> get props => [message, title];
}
