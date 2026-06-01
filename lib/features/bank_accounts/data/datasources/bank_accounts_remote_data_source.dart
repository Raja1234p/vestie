import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/bank_account_model.dart';

abstract class BankAccountsRemoteDataSource {
  Future<List<BankAccountModel>> list();

  Future<BankAccountModel> link({String? bankAccountToken});

  Future<void> remove(String bankAccountId);
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
  Future<BankAccountModel> link({String? bankAccountToken}) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.bankAccounts,
      data: bankAccountToken != null
          ? {'bankAccountToken': bankAccountToken}
          : <String, dynamic>{},
    );
    if (response['bankAccount'] is Map) {
      return BankAccountModel.fromJson(
        (response['bankAccount'] as Map).cast<String, dynamic>(),
      );
    }
    return BankAccountModel.fromJson(response);
  }

  @override
  Future<void> remove(String bankAccountId) async {
    await apiClient.delete(ApiConstants.bankAccount(bankAccountId));
  }
}
