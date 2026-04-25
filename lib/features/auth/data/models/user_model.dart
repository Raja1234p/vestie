import '../../domain/entities/user.dart';

/// Data model for the user profile returned by /users/me.
/// Extends the pure domain [User] entity with JSON serialisation.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.isVerified,
    super.accessToken,
    super.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final firstName = (json['firstName'] as String?) ?? '';
    final lastName  = (json['lastName']  as String?) ?? '';
    final fullName  = (json['fullName']  as String?)
        ?? '$firstName $lastName'.trim();

    return UserModel(
      id:           (json['id']       as String?) ?? '',
      name:         fullName,
      email:        (json['email']    as String?) ?? '',
      isVerified:   (json['emailConfirmed'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':    id,
        'email': email,
        'name':  name,
      };
}
