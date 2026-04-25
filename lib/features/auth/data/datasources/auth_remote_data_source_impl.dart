import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';
import '../models/register_response_model.dart';
import '../models/message_response_model.dart';
import '../models/risk_disclaimer_model.dart';
import 'auth_remote_data_source.dart';
import '../../../../core/utils/logger.dart';
import 'package:dio/dio.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  Never _handleError(DioException e, String defaultMessage) {
    String message = defaultMessage;
    String? title;
    
    if (e.response?.data != null && e.response?.data is Map) {
      final data = e.response!.data as Map;
      // Backend usually returns error in 'detail' or 'message' or 'title'
      message = data['detail']?.toString() ?? 
                data['message']?.toString() ?? 
                defaultMessage;
      
      title = data['title']?.toString();
    }

    if (e.response?.statusCode == 401) {
      throw UnauthorizedException(message, title);
    }
    throw ServerException(message, title);
  }

  @override
  Future<AuthTokenModel> login({
    required String email,
    required String password,
    required String deviceName,
    required String ipAddress,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
          'deviceName': deviceName,
          'ipAddress': ipAddress,
        },
      );
      return AuthTokenModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error('API Login Error: ${e.response?.statusCode}', error: e.response?.data);
      _handleError(e, 'Login failed');
    }
  }

  @override
  Future<RegisterResponseModel> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.register,
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      return RegisterResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error('API Register Error: ${e.response?.statusCode}', error: e.response?.data);
      _handleError(e, 'Registration failed');
    }
  }

  @override
  Future<AuthTokenModel> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.verifyEmail,
        data: {
          'email': email,
          'code': code,
        },
      );
      return AuthTokenModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error('API VerifyEmail Error: ${e.response?.statusCode}', error: e.response?.data);
      _handleError(e, 'Email verification failed');
    }
  }

  @override
  Future<MessageResponseModel> resendCode({
    required String email,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.resendCode,
        data: {
          'email': email,
        },
      );
      return MessageResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error('API ResendCode Error: ${e.response?.statusCode}', error: e.response?.data);
      _handleError(e, 'Resending code failed');
    }
  }

  @override
  Future<MessageResponseModel> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.forgotPassword,
        data: {
          'email': email,
        },
      );
      return MessageResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error('API ForgotPassword Error: ${e.response?.statusCode}', error: e.response?.data);
      _handleError(e, 'Forgot password request failed');
    }
  }

  @override
  Future<MessageResponseModel> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        },
      );
      return MessageResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error('API ResetPassword Error: ${e.response?.statusCode}', error: e.response?.data);
      _handleError(e, 'Password reset failed');
    }
  }

  @override
  Future<MessageResponseModel> logout({
    required String refreshToken,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.logout,
        data: refreshToken,
      );
      return MessageResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error('API Logout Error: ${e.response?.statusCode}', error: e.response?.data);
      _handleError(e, 'Logout failed');
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await _client.get(ApiConstants.me);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error('API GetMe Error: ${e.response?.statusCode}', error: e.response?.data);
      _handleError(e, 'Failed to get user profile');
    }
  }

  @override
  Future<RiskDisclaimerModel> getRiskDisclaimer() async {
    try {
      final response = await _client.get(ApiConstants.riskDisclaimer);
      return RiskDisclaimerModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error('API GetRiskDisclaimer Status Error: ${e.response?.statusCode}', error: e.response?.data);
      _handleError(e, 'Failed to get risk disclaimer status');
    }
  }

  @override
  Future<MessageResponseModel> acceptRiskDisclaimer({
    required String version,
    required String ipAddress,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.riskDisclaimer,
        data: {
          'disclaimerVersion': version,
          'ipAddress': ipAddress,
        },
      );
      return MessageResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error('API AcceptRiskDisclaimer Error: ${e.response?.statusCode}', error: e.response?.data);
      _handleError(e, 'Failed to accept risk disclaimer');
    }
  }

  @override
  Future<AuthTokenModel> loginWithGoogle({
    required String idToken,
    required String deviceName,
    required String ipAddress,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.googleLogin,
        data: {
          'idToken': idToken,
          'deviceName': deviceName,
          'ipAddress': ipAddress,
        },
      );
      return AuthTokenModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error('API GoogleLogin Error: ${e.response?.statusCode}', error: e.response?.data);
      _handleError(e, 'Google login failed');
    }
  }
}
