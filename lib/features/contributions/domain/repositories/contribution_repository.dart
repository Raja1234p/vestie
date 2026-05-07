import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/contribution_config_entity.dart';
import '../entities/contribution_preview_entity.dart';

abstract class ContributionRepository {
  Future<Either<Failure, ContributionConfigEntity>> getContributionConfig(String projectId);
  Future<Either<Failure, ContributionPreviewEntity>> previewContribution({
    required String projectId,
    required String membershipId,
    required String walletId,
    required double amount,
    required String currency,
    String? externalReference,
    required bool confirmNonRefundable,
  });
  Future<Either<Failure, void>> confirmContribution({
    required String projectId,
    required String membershipId,
    required String walletId,
    required double amount,
    required String currency,
    String? externalReference,
    required bool confirmNonRefundable,
  });
}
