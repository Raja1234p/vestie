import 'package:equatable/equatable.dart';

class VerifyResetCodeResult extends Equatable {
  final String userId;
  final String message;

  const VerifyResetCodeResult({
    required this.userId,
    required this.message,
  });

  @override
  List<Object?> get props => [userId, message];
}
