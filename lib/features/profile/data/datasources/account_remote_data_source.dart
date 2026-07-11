import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/api_response_body.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/account_deletion_eligibility_model.dart';
abstract class AccountRemoteDataSource {
  Future<AccountDeletionEligibilityModel> getDeletionEligibility();

  Future<void> deleteAccount({required bool confirmed});
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  AccountRemoteDataSourceImpl({required this.apiClient});

  final BaseApiClient apiClient;

  @override
  Future<AccountDeletionEligibilityModel> getDeletionEligibility() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.accountDeletionEligibility,
    );
    return AccountDeletionEligibilityModel.fromJson(
      unwrapApiResponseBody(response),
    );
  }

  @override
  Future<void> deleteAccount({required bool confirmed}) async {
    await apiClient.post<dynamic>(
      ApiConstants.accountDelete,
      data: <String, dynamic>{'confirmed': confirmed},
    );
  }
}
