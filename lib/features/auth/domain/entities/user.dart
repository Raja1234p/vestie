import 'package:equatable/equatable.dart';

/// Core user entity — pure domain, no JSON/API dependency.
class User extends Equatable {
  final String id;
  final String name;
  final String email;

  /// Handle from `GET/PUT /users/me` (`userName` in JSON).
  final String userName;
  final String? photoUrl;
  final bool isVerified;
  final String? accessToken;
  final String? refreshToken;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.userName = '',
    this.photoUrl,
    this.isVerified = false,
    this.accessToken,
    this.refreshToken,
  });

  @override
  List<Object?> get props => [id, name, email, userName, photoUrl, isVerified];
}
