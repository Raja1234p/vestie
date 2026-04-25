import '../../domain/entities/user.dart';

/// Data model representing the token pair returned by the API on login/refresh.
/// Maps directly to the JSON response from /auth/login and /auth/refresh.
class AuthTokenModel extends User {
  const AuthTokenModel({
    required String accessToken,
    required String refreshToken,
  }) : super(
          id: '',
          name: '',
          email: '',
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    // API v1 wraps tokens in a 'tokens' object for login/verify, but not for refresh.
    final tokenData = json['tokens'] != null 
        ? json['tokens'] as Map<String, dynamic> 
        : json;

    return AuthTokenModel(
      accessToken: (tokenData['accessToken'] as String?) ?? '',
      refreshToken: (tokenData['refreshToken'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken ?? '',
        'refreshToken': refreshToken ?? '',
      };
}
