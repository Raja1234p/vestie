import '../../../../core/utils/safe_parser.dart';
import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.userName,
    required super.firstName,
    required super.lastName,
    super.photoUrl,
    required super.isEmailVerified,
    required super.status,
    super.riskAcceptedAtUtc,
    required super.roles,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json.safeString('id'),
      email: json.safeString('email'),
      userName: json.safeString('userName'),
      firstName: json.safeString('firstName'),
      lastName: json.safeString('lastName'),
      photoUrl: _photoUrl(json),
      isEmailVerified: json.safeBool('isEmailVerified'),
      status: json.safeString('status'),
      riskAcceptedAtUtc: json.safeDateTimeUtc('riskAcceptedAtUtc'),
      roles: json.safeList('roles').map((e) => e.toString()).toList(),
    );
  }

  static String? _photoUrl(Map<String, dynamic> json) {
    for (final key in ['profilePhotoUrl', 'photoUrl', 'photoURL']) {
      final value = json.safeStringNullable(key);
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      'status': status,
      'riskAcceptedAtUtc': riskAcceptedAtUtc?.toIso8601String(),
      'roles': roles,
    };
  }
}
