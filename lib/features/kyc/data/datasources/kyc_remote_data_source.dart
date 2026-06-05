import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/kyc_models.dart';

abstract class KycRemoteDataSource {
  Future<KycStatusModel> getStatus();

  Future<KycStartResultModel> start({
    String country,
    String? refreshUrl,
    String? returnUrl,
  });
}

class KycRemoteDataSourceImpl implements KycRemoteDataSource {
  final BaseApiClient apiClient;

  KycRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<KycStatusModel> getStatus() async {
    final response =
        await apiClient.get<Map<String, dynamic>>(ApiConstants.kycStatus);
    return KycStatusModel.fromJson(response);
  }

  @override
  Future<KycStartResultModel> start({
    String country = 'US',
    String? refreshUrl,
    String? returnUrl,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.kycStart,
      data: {
        'country': country,
        'refreshUrl': ?refreshUrl,
        'returnUrl': ?returnUrl,
      },
    );
    return KycStartResultModel.fromJson(response);
  }
}
