import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String email;
  final String userName;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final bool isEmailVerified;
  final String status;
  final DateTime? riskAcceptedAtUtc;
  final List<String> roles;

  const UserProfileEntity({
    required this.id,
    required this.email,
    required this.userName,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    required this.isEmailVerified,
    required this.status,
    this.riskAcceptedAtUtc,
    required this.roles,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id,
    email,
    userName,
    firstName,
    lastName,
    photoUrl,
    isEmailVerified,
    status,
    riskAcceptedAtUtc,
    roles,
  ];
}
