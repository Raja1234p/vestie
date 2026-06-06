import '../models/contribution_config_model.dart';
import '../models/contribution_confirm_model.dart';
import '../models/contribution_preview_model.dart';
import '../models/contribution_record_model.dart';

class ContributionRequest {
  final String projectId;
  final String membershipId;
  final String walletId;
  final double amount;
  final String currency;
  final String? externalReference;
  final bool confirmNonRefundable;

  const ContributionRequest({
    required this.projectId,
    required this.membershipId,
    required this.walletId,
    required this.amount,
    required this.currency,
    required this.externalReference,
    required this.confirmNonRefundable,
  });

  Map<String, dynamic> toJson() => {
    'projectId': projectId,
    'membershipId': membershipId,
    'walletId': walletId,
    'amount': amount,
    'currency': currency,
    'externalReference': externalReference,
    'confirmNonRefundable': confirmNonRefundable,
  };
}

abstract class ContributionsRemoteDataSource {
  Future<ContributionConfigModel> getConfig({required String projectId});

  Future<ContributionPreviewModel> preview({
    required ContributionRequest request,
  });

  Future<ContributionConfirmModel> confirm({
    required ContributionRequest request,
  });

  Future<List<ContributionRecordModel>> listByProject({
    required String projectId,
  });

  Future<ContributionRecordModel> getById({required String id});

  Future<double> getProjectPotBalance({required String projectId});

  Future<double> getWalletAvailableBalance({required String walletId});

  Future<String> awardVffBadge({required String projectId});
}
