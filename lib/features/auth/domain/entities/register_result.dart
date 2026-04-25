import 'package:equatable/equatable.dart';

class RegisterResult extends Equatable {
  final String userId;
  final bool requiresEmailVerification;

  const RegisterResult({
    required this.userId,
    required this.requiresEmailVerification,
  });

  @override
  List<Object?> get props => [userId, requiresEmailVerification];
}
