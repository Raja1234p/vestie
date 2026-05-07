import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_api_client.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getMyProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final BaseApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserProfileModel> getMyProfile() async {
    final response = await apiClient.get<Map<String, dynamic>>(ApiConstants.me);
    return UserProfileModel.fromJson(response);
  }
}
