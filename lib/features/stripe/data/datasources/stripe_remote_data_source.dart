import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/stripe_config_model.dart';
import '../models/stripe_processing_fee_model.dart';

abstract class StripeRemoteDataSource {
  Future<StripeConfigModel> getConfig();

  Future<StripeProcessingFeeModel> getProcessingFee({
    double? amount,
    String? paymentIntentId,
  });
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

  @override
  Future<StripeProcessingFeeModel> getProcessingFee({
    double? amount,
    String? paymentIntentId,
  }) async {
    final query = <String, dynamic>{};
    final intentId = paymentIntentId?.trim() ?? '';
    if (intentId.isNotEmpty) {
      query['paymentIntentId'] = intentId;
    } else if (amount != null) {
      query['amount'] = amount.toString();
    }
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.stripeProcessingFee,
      queryParameters: query,
    );
    return StripeProcessingFeeModel.fromJson(response);
  }
}
