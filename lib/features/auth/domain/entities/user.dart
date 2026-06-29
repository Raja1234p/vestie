import 'package:equatable/equatable.dart';

/// Core user entity — pure domain, no JSON/API dependency.
class User extends Equatable {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
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
    this.firstName = '',
    this.lastName = '',
    required this.email,
    this.userName = '',
    this.photoUrl,
    this.isVerified = false,
    this.accessToken,
    this.refreshToken,
  });

  String get fullName {
    final combined = '$firstName $lastName'.trim();
    return combined.isNotEmpty ? combined : name;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    firstName,
    lastName,
    email,
    userName,
    photoUrl,
    isVerified,
  ];
}
