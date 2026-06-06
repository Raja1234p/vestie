import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/stripe_config_model.dart';

abstract class StripeRemoteDataSource {
  Future<StripeConfigModel> getConfig();
}

class StripeRemoteDataSourceImpl implements StripeRemoteDataSource {
  final BaseApiClient apiClient;

  StripeRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<StripeConfigModel> getConfig() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.stripeConfig,
    );
    return StripeConfigModel.fromJson(response);
  }
}
