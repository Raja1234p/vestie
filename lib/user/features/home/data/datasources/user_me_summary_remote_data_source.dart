import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/user_me_summary_model.dart';

abstract class UserMeSummaryRemoteDataSource {
  Future<UserMeSummaryModel> getSummary();
}

class UserMeSummaryRemoteDataSourceImpl
    implements UserMeSummaryRemoteDataSource {
  final BaseApiClient apiClient;

  UserMeSummaryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserMeSummaryModel> getSummary() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.meSummary,
    );
    return UserMeSummaryModel.fromJson(response);
  }
}
