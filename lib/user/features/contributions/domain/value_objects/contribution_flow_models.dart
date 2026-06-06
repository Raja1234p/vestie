import 'package:equatable/equatable.dart';
import '../../data/datasources/contributions_remote_data_source.dart';
import '../../data/models/contribution_config_model.dart';
import '../../data/models/contribution_confirm_model.dart';
import '../../data/models/contribution_preview_model.dart';

class ContributionInput extends Equatable {
  final String projectId;
  final double amount;
  final String walletId;

  const ContributionInput({
    required this.projectId,
    required this.amount,
    required this.walletId,
  });

  ContributionRequest toRequest() {
    return ContributionRequest(
      projectId: projectId,
      membershipId: '',
      walletId: walletId,
      amount: amount,
      currency: 'USD',
      externalReference: null,
      confirmNonRefundable: true,
    );
  }

  @override
  List<Object?> get props => [projectId, amount, walletId];
}

class ContributionPreview extends Equatable {
  final double amount;
  final double platformFee;
  final double totalDeduction;
  final String currency;

  const ContributionPreview({
    required this.amount,
    required this.platformFee,
    required this.totalDeduction,
    required this.currency,
  });

  factory ContributionPreview.fromModel(ContributionPreviewModel model) {
    return ContributionPreview(
      amount: model.amount,
      platformFee: model.platformFee,
      totalDeduction: model.totalDeduction,
      currency: model.currency,
    );
  }

  @override
  List<Object?> get props => [amount, platformFee, totalDeduction, currency];
}

class ContributionConfig extends Equatable {
  final String projectId;
  final List<dynamic> wallets;

  const ContributionConfig({required this.projectId, required this.wallets});

  factory ContributionConfig.fromModel(ContributionConfigModel model) {
    return ContributionConfig(
      projectId: model.projectId,
      wallets: model.wallets,
    );
  }

  @override
  List<Object?> get props => [projectId, wallets];
}

class ContributionResult extends Equatable {
  final bool success;

  const ContributionResult({required this.success});

  factory ContributionResult.fromModel(ContributionConfirmModel model) {
    return const ContributionResult(success: true);
  }

  @override
  List<Object?> get props => [success];
}
