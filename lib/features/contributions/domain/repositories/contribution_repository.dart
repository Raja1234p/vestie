import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/contribution_config_entity.dart';
import '../entities/contribution_preview_entity.dart';

abstract class ContributionRepository {
  Future<Either<Failure, ContributionConfigEntity>> getContributionConfig(String projectId);
  Future<Either<Failure, ContributionPreviewEntity>> previewContribution(String projectId, double amount);
  Future<Either<Failure, void>> confirmContribution(String projectId, double amount, String walletId);
}
