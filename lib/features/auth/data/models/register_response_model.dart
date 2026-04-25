/// Response from /auth/register
class RegisterResponseModel {
  final String userId;
  final bool requiresEmailVerification;

  const RegisterResponseModel({
    required this.userId,
    required this.requiresEmailVerification,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      userId: json['userId'] as String? ?? '',
      requiresEmailVerification: json['requiresEmailVerification'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'requiresEmailVerification': requiresEmailVerification,
      };
}
