import 'dart:convert';

import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';
import '../models/register_response_model.dart';
import '../models/message_response_model.dart';
import '../models/verify_reset_code_response_model.dart';
import '../../domain/entities/update_me_photo.dart';
import '../models/risk_disclaimer_model.dart';
import 'auth_remote_data_source.dart';
import '../../../../core/utils/logger.dart';
import 'package:dio/dio.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  Never _handleError(DioException e, String defaultMessage) {
    if (e.type == DioExceptionType.cancel) {
      throw ServerException(defaultMessage, null);
    }
    // No HTTP response — wrong credentials vs offline both used to show "Login failed".
    if (e.response == null) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ServerException(AppStrings.errorTimeout, null);
      }
      throw ServerException(
        AppStrings.errorNetwork,
        AppStrings.errorDialogOfflineTitle,
      );
    }

    String message = defaultMessage;
    String? title;

    if (e.response?.data != null && e.response?.data is Map) {
      final data = e.response!.data as Map;
      // Backend usually returns error in 'detail' or 'message' or 'title'
      message =
          data['detail']?.toString() ??
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
    required String deviceId,
    required String deviceName,
    required String ipAddress,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
          'deviceId': deviceId,
          'deviceName': deviceName,
          'ipAddress': ipAddress,
        },
      );
      return AuthTokenModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error(
        'API Login Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
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
      AppLogger.error(
        'API Register Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
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
        data: {'email': email, 'code': code},
      );
      return AuthTokenModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error(
        'API VerifyEmail Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Email verification failed');
    }
  }

  @override
  Future<MessageResponseModel> resendCode({required String email}) async {
    try {
      final response = await _client.post(
        ApiConstants.resendCode,
        data: {'email': email},
      );
      return MessageResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error(
        'API ResendCode Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Resending code failed');
    }
  }

  @override
  Future<MessageResponseModel> forgotPassword({required String email}) async {
    try {
      final response = await _client.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      return MessageResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error(
        'API ForgotPassword Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Forgot password request failed');
    }
  }

  @override
  Future<VerifyResetCodeResponseModel> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.verifyResetCode,
        data: {'email': email, 'code': code},
      );
      return VerifyResetCodeResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      AppLogger.error(
        'API VerifyResetCode Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Reset code verification failed');
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
      AppLogger.error(
        'API ResetPassword Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Password reset failed');
    }
  }

  @override
  Future<MessageResponseModel> logout({required String refreshToken}) async {
    try {
      // API contract: body is a JSON string (not `{ "refreshToken": "..." }`).
      final response = await _client.post(
        ApiConstants.logout,
        data: jsonEncode(refreshToken),
      );
      return MessageResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error(
        'API Logout Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Logout failed');
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await _client.get(ApiConstants.me);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error(
        'API GetMe Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to get user profile');
    }
  }

  @override
  Future<UserModel> updateMe({
    required String firstName,
    required String lastName,
    required String userName,
    UpdateMePhoto photo = const UpdateMePhotoUnchanged(),
  }) async {
    try {
      final formData = await _buildUpdateMeFormData(
        firstName: firstName,
        lastName: lastName,
        userName: userName,
        photo: photo,
      );
      final response = await _client.put(ApiConstants.me, data: formData);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error(
        'API UpdateMe Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to update user profile');
    }
  }

  Future<FormData> _buildUpdateMeFormData({
    required String firstName,
    required String lastName,
    required String userName,
    required UpdateMePhoto photo,
  }) async {
    final formData = FormData.fromMap({
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
    });

    switch (photo) {
      case UpdateMePhotoUpload(:final filePath):
        final path = filePath.trim();
        formData.files.add(
          MapEntry(
            'file',
            await MultipartFile.fromFile(
              path,
              filename: path.split(RegExp(r'[/\\]')).last,
            ),
          ),
        );
      case UpdateMePhotoRemove():
        break;
      case UpdateMePhotoUnchanged():
        break;
    }

    return formData;
  }

  @override
  Future<UserModel> deleteMeProfilePicture() async {
    try {
      final response = await _client.delete(ApiConstants.meProfilePicture);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return UserModel.fromJson(data);
      }
      if (data is Map) {
        return UserModel.fromJson(data.cast<String, dynamic>());
      }
      return getMe();
    } on DioException catch (e) {
      AppLogger.error(
        'API DeleteMeProfilePicture Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to remove profile photo');
    }
  }

  @override
  Future<RiskDisclaimerModel> getRiskDisclaimer() async {
    try {
      final response = await _client.get(ApiConstants.riskDisclaimer);
      return RiskDisclaimerModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error(
        'API GetRiskDisclaimer Status Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
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
        data: {'disclaimerVersion': version, 'ipAddress': ipAddress},
      );
      return MessageResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error(
        'API AcceptRiskDisclaimer Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to accept risk disclaimer');
    }
  }

  @override
  Future<AuthTokenModel> loginWithGoogle({
    required String idToken,
    required String deviceId,
    required String deviceName,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.googleLogin,
        data: {
          'idToken': idToken,
          'deviceId': deviceId,
          'deviceName': deviceName,
          'ipAddress': ApiConstants.defaultIpAddress,
        },
      );
      return AuthTokenModel.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error(
        'API GoogleLogin Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, AppStrings.errorGoogleSignInFailed);
    }
  }
}
