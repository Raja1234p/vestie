import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();
}

class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  final String email;
  const ForgotPasswordSubmitted({required this.email});
  @override
  List<Object> get props => [email];
}

class ForgotPasswordReset extends ForgotPasswordEvent {
  const ForgotPasswordReset();
  @override
  List<Object> get props => [];
}
