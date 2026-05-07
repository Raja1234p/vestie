import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/contribution_config_entity.dart';
import '../../domain/entities/contribution_preview_entity.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../datasources/contribution_remote_data_source.dart';

class ContributionRepositoryImpl implements ContributionRepository {
  final ContributionRemoteDataSource remoteDataSource;

  ContributionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ContributionConfigEntity>> getContributionConfig(String projectId) async {
    try {
      final config = await remoteDataSource.getContributionConfig(projectId);
      return Right(config);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ContributionPreviewEntity>> previewContribution({
    required String projectId,
    required String membershipId,
    required String walletId,
    required double amount,
    required String currency,
    String? externalReference,
    required bool confirmNonRefundable,
  }) async {
    try {
      final preview = await remoteDataSource.previewContribution(
        projectId: projectId,
        membershipId: membershipId,
        walletId: walletId,
        amount: amount,
        currency: currency,
        externalReference: externalReference,
        confirmNonRefundable: confirmNonRefundable,
      );
      return Right(preview);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> confirmContribution({
    required String projectId,
    required String membershipId,
    required String walletId,
    required double amount,
    required String currency,
    String? externalReference,
    required bool confirmNonRefundable,
  }) async {
    try {
      await remoteDataSource.confirmContribution(
        projectId: projectId,
        membershipId: membershipId,
        walletId: walletId,
        amount: amount,
        currency: currency,
        externalReference: externalReference,
        confirmNonRefundable: confirmNonRefundable,
      );
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
