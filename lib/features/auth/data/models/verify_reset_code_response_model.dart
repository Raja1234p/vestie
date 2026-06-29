/// Response from `POST /auth/verify-reset-code`.
class VerifyResetCodeResponseModel {
  final String userId;
  final String message;

  const VerifyResetCodeResponseModel({
    required this.userId,
    required this.message,
  });

  factory VerifyResetCodeResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyResetCodeResponseModel(
      userId: json['userId'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}
