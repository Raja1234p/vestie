import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/user_guidelines_model.dart';

abstract class UserGuidelinesRemoteDataSource {
  Future<UserGuidelinesModel> getUserGuidelines();
}

class UserGuidelinesRemoteDataSourceImpl
    implements UserGuidelinesRemoteDataSource {
  UserGuidelinesRemoteDataSourceImpl({required this.apiClient});

  final BaseApiClient apiClient;

  @override
  Future<UserGuidelinesModel> getUserGuidelines() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.contentUserGuidelines,
    );
    return UserGuidelinesModel.fromJson(response);
  }
}
