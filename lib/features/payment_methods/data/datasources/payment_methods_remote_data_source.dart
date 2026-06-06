import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/api_response_body.dart';
import 'package:vestie/core/network/base_api_client.dart';
import 'package:vestie/core/utils/safe_parser.dart';

import '../models/payment_method_api_model.dart';

class SetupIntentResultModel {
  final String clientSecret;
  final String? setupIntentId;

  const SetupIntentResultModel({
    required this.clientSecret,
    this.setupIntentId,
  });

  factory SetupIntentResultModel.fromJson(Map<String, dynamic> json) {
    var body = unwrapApiResponseBody(json);
    final nested = body['setupIntent'] ?? body['setup_intent'];
    if (nested is Map) {
      body = Map<String, dynamic>.from(nested);
    }

    return SetupIntentResultModel(
      clientSecret: body.safeString(
        'clientSecret',
        defaultValue: body.safeString(
          'client_secret',
          defaultValue: body.safeString('setupIntentClientSecret'),
        ),
      ),
      setupIntentId: body.safeString(
        'setupIntentId',
        defaultValue: body.safeString('setup_intent_id'),
      ),
    );
  }
}

abstract class PaymentMethodsRemoteDataSource {
  Future<List<PaymentMethodApiModel>> list();

  Future<PaymentMethodApiModel> getById(String paymentMethodId);

  Future<SetupIntentResultModel> createSetupIntent();

  Future<PaymentMethodApiModel> attachPaymentMethod({
    required String paymentMethodId,
  });

  Future<void> setPrimary(String paymentMethodId, {required bool isPrimary});

  Future<void> remove(String paymentMethodId);
}

class PaymentMethodsRemoteDataSourceImpl
    implements PaymentMethodsRemoteDataSource {
  final BaseApiClient apiClient;

  PaymentMethodsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PaymentMethodApiModel>> list() async {
    final response = await apiClient.get<dynamic>(ApiConstants.paymentMethods);
    if (response is List) {
      return response
          .whereType<Map>()
          .map((e) => PaymentMethodApiModel.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false);
    }
    if (response is Map && response['items'] is List) {
      return (response['items'] as List)
          .whereType<Map>()
          .map((e) => PaymentMethodApiModel.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false);
    }
    return const [];
  }

  @override
  Future<PaymentMethodApiModel> getById(String paymentMethodId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.paymentMethod(paymentMethodId),
    );
    return PaymentMethodApiModel.fromJson(response);
  }

  @override
  Future<SetupIntentResultModel> createSetupIntent() async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.paymentMethodsSetupIntent,
    );
    return SetupIntentResultModel.fromJson(response);
  }

  static PaymentMethodApiModel _parsePaymentMethodResponse(
    Map<String, dynamic> response,
  ) {
    final body = unwrapApiResponseBody(response);
    final nested = body['paymentMethod'];
    if (nested is Map) {
      return PaymentMethodApiModel.fromJson(nested.cast<String, dynamic>());
    }
    return PaymentMethodApiModel.fromJson(body);
  }

  @override
  Future<PaymentMethodApiModel> attachPaymentMethod({
    required String paymentMethodId,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.paymentMethods,
      data: {'paymentMethodId': paymentMethodId},
    );
    return _parsePaymentMethodResponse(response);
  }

  @override
  Future<void> setPrimary(
    String paymentMethodId, {
    required bool isPrimary,
  }) async {
    await apiClient.patch<Map<String, dynamic>>(
      ApiConstants.paymentMethodPrimary(paymentMethodId),
      data: {'isPrimary': isPrimary},
    );
  }

  @override
  Future<void> remove(String paymentMethodId) async {
    await apiClient.delete(ApiConstants.paymentMethod(paymentMethodId));
  }
}
