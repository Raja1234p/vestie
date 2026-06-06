import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/bank_account_model.dart';
import '../models/bank_link_result_model.dart';

abstract class BankAccountsRemoteDataSource {
  Future<List<BankAccountModel>> list();

  Future<BankLinkResultModel> link({
    String? bankAccountToken,
    String? refreshUrl,
    String? returnUrl,
  });

  Future<void> remove(String bankAccountId);

  Future<void> setDefault(String bankAccountId, {required bool isDefault});
}

class BankAccountsRemoteDataSourceImpl implements BankAccountsRemoteDataSource {
  final BaseApiClient apiClient;

  BankAccountsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<BankAccountModel>> list() async {
    final response = await apiClient.get<dynamic>(ApiConstants.bankAccounts);
    if (response is List) {
      return response
          .whereType<Map>()
          .map((e) => BankAccountModel.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false);
    }
    return const [];
  }

  @override
  Future<BankLinkResultModel> link({
    String? bankAccountToken,
    String? refreshUrl,
    String? returnUrl,
  }) async {
    final data = <String, dynamic>{};
    if (bankAccountToken != null && bankAccountToken.isNotEmpty) {
      data['bankAccountToken'] = bankAccountToken;
    } else {
      if (refreshUrl != null) data['refreshUrl'] = refreshUrl;
      if (returnUrl != null) data['returnUrl'] = returnUrl;
    }

    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.bankAccounts,
      data: data,
    );
    return BankLinkResultModel.fromJson(response);
  }

  @override
  Future<void> remove(String bankAccountId) async {
    await apiClient.delete(ApiConstants.bankAccount(bankAccountId));
  }

  @override
  Future<void> setDefault(
    String bankAccountId, {
    required bool isDefault,
  }) async {
    await apiClient.patch<Map<String, dynamic>>(
      ApiConstants.bankAccountDefault(bankAccountId),
      data: {'isDefault': isDefault},
    );
  }
}
