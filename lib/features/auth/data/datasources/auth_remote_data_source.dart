import '../models/auth_token_model.dart';
import '../models/user_model.dart';
import '../models/register_response_model.dart';
import '../models/message_response_model.dart';
import '../models/risk_disclaimer_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> login({
    required String email,
    required String password,
    required String deviceName,
    required String ipAddress,
  });

  Future<RegisterResponseModel> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<AuthTokenModel> verifyEmail({
    required String email,
    required String code,
  });

  Future<MessageResponseModel> resendCode({
    required String email,
  });

  Future<MessageResponseModel> forgotPassword({
    required String email,
  });

  Future<MessageResponseModel> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  });

  Future<MessageResponseModel> logout({
    required String refreshToken,
  });

  Future<UserModel> getMe();

  Future<RiskDisclaimerModel> getRiskDisclaimer();

  Future<MessageResponseModel> acceptRiskDisclaimer({
    required String version,
    required String ipAddress,
  });

  Future<AuthTokenModel> loginWithGoogle({
    required String idToken,
  });
}
