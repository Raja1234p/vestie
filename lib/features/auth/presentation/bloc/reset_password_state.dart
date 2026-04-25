import 'package:equatable/equatable.dart';

abstract class ResetPasswordState extends Equatable {
  const ResetPasswordState();
}

class ResetPasswordInitial extends ResetPasswordState {
  const ResetPasswordInitial();
  @override List<Object> get props => [];
}

class ResetPasswordLoading extends ResetPasswordState {
  const ResetPasswordLoading();
  @override List<Object> get props => [];
}

class ResetPasswordSuccess extends ResetPasswordState {
  const ResetPasswordSuccess();
  @override List<Object> get props => [];
}

class ResetPasswordError extends ResetPasswordState {
  final String message;
  final String? title;
  const ResetPasswordError({required this.message, this.title});
  @override List<Object?> get props => [message, title];
}
