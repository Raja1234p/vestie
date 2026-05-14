import '../../domain/entities/user.dart';

/// Data model for the user profile returned by /users/me.
/// Extends the pure domain [User] entity with JSON serialisation.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.userName,
    super.photoUrl,
    super.isVerified,
    super.accessToken,
    super.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final firstName = (json['firstName'] as String?) ?? '';
    final lastName  = (json['lastName']  as String?) ?? '';
    final fullName  = (json['fullName']  as String?)
        ?? '$firstName $lastName'.trim();
    final email = (json['email'] as String?) ?? '';
    final handle = (json['userName'] as String?)?.trim() ?? '';
    final rawPhoto = (json['photoUrl'] as String?)?.trim();

    return UserModel(
      id:           (json['id']       as String?) ?? '',
      name:         fullName,
      email:        email,
      userName:     handle,
      photoUrl:     rawPhoto != null && rawPhoto.isNotEmpty ? rawPhoto : null,
      isVerified:   (json['isEmailVerified'] as bool?) ??
          (json['emailConfirmed'] as bool?) ??
          false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':    id,
        'email': email,
        'name':  name,
      };
}
