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
  final bool isDisclaimerAccepted;

  const LoginSuccess({
    required this.user,
    this.isDisclaimerAccepted = false,
  });

  @override
  List<Object> get props => [user, isDisclaimerAccepted];
}

class LoginError extends LoginState {
  final String message;
  final String? title;
  const LoginError({required this.message, this.title});
  @override
  List<Object?> get props => [message, title];
}
