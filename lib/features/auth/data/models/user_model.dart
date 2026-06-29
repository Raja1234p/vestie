import '../../domain/entities/user.dart';

/// Data model for the user profile returned by /users/me.
/// Extends the pure domain [User] entity with JSON serialisation.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    super.firstName,
    super.lastName,
    required super.email,
    super.userName,
    super.photoUrl,
    super.isVerified,
    super.accessToken,
    super.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final firstName = (json['firstName'] as String?)?.trim() ?? '';
    final lastName = (json['lastName'] as String?)?.trim() ?? '';
    final fullName =
        (json['fullName'] as String?)?.trim() ?? '$firstName $lastName'.trim();
    final email = (json['email'] as String?) ?? '';
    final handle = (json['userName'] as String?)?.trim() ?? '';
    final rawPhoto =
        (json['profilePhotoUrl'] as String?)?.trim() ??
        (json['photoUrl'] as String?)?.trim() ??
        (json['photoURL'] as String?)?.trim();

    return UserModel(
      id: (json['id'] as String?) ?? '',
      name: fullName,
      firstName: firstName,
      lastName: lastName,
      email: email,
      userName: handle,
      photoUrl: rawPhoto != null && rawPhoto.isNotEmpty ? rawPhoto : null,
      isVerified:
          (json['isEmailVerified'] as bool?) ??
          (json['emailConfirmed'] as bool?) ??
          false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'firstName': firstName,
    'lastName': lastName,
    'fullName': fullName,
  };
}
