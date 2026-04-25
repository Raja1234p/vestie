import 'package:equatable/equatable.dart';

/// Core user entity — pure domain, no JSON/API dependency.
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final bool isVerified;
  final String? accessToken;
  final String? refreshToken;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.isVerified = false,
    this.accessToken,
    this.refreshToken,
  });

  @override
  List<Object?> get props => [id, name, email, isVerified];
}
