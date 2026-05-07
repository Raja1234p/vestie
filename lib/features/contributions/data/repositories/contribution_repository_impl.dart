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
  Future<Either<Failure, ContributionPreviewEntity>> previewContribution(String projectId, double amount) async {
    try {
      final preview = await remoteDataSource.previewContribution(projectId, amount);
      return Right(preview);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> confirmContribution(String projectId, double amount, String walletId) async {
    try {
      await remoteDataSource.confirmContribution(projectId, amount, walletId);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
