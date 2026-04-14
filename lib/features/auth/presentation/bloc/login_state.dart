import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class LoginState extends Equatable {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
  @override
  List<Object> get props => [];
}

class LoginLoading extends LoginState {
  const LoginLoading();
  @override
  List<Object> get props => [];
}

class LoginSuccess extends LoginState {
  final User user;
  const LoginSuccess({required this.user});
  @override
  List<Object> get props => [user];
}

class LoginError extends LoginState {
  final String message;
  const LoginError({required this.message});
  @override
  List<Object> get props => [message];
}
