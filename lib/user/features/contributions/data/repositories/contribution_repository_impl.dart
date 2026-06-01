import 'package:dartz/dartz.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/utils/contribution_fee_policy.dart';
import 'package:vestie/core/utils/idempotency_key.dart';
import 'package:vestie/features/wallet/domain/entities/wallet_entity.dart';
import 'package:vestie/features/wallet/domain/repositories/wallet_repository.dart';

import '../../domain/contribution_config_defaults.dart';
import '../../domain/entities/contribution_config_entity.dart';
import '../../domain/entities/contribution_preview_entity.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../datasources/contribution_remote_data_source.dart';

class ContributionRepositoryImpl implements ContributionRepository {
  final ContributionRemoteDataSource remoteDataSource;
  final WalletRepository walletRepository;

  ContributionRepositoryImpl({
    required this.remoteDataSource,
    required this.walletRepository,
  });

  @override
  Future<Either<Failure, ContributionConfigEntity>> getContributionConfig(
    String projectId,
  ) async {
    try {
      await remoteDataSource.getContributionConfig(projectId);
      final wallets = await _loadWalletSummaries();
      return Right(defaultContributionConfig(projectId, wallets: wallets));
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
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
    final validation = ContributionFeePolicy.validateAmount(amount);
    if (validation != null) {
      return Left(ValidationFailure(validation));
    }
    final fee = ContributionFeePolicy.platformFee(amount);
    return Right(
      ContributionPreviewEntity(
        amount: amount,
        platformFee: fee,
        totalDeduction: amount + fee,
        currency: currency,
      ),
    );
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
      await remoteDataSource.submitProjectContribution(
        projectId: projectId,
        amount: amount,
        confirmNonRefundable: confirmNonRefundable,
        idempotencyKey: newIdempotencyKey('contribute'),
      );
      await walletRepository.getWallet(forceRefresh: true);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  Future<List<WalletSummaryEntity>> _loadWalletSummaries() async {
    final result = await walletRepository.getWallet();
    return result.fold(
      (_) => const [],
      (WalletEntity w) => [
        WalletSummaryEntity(
          walletId: w.walletId,
          currency: w.currency,
          availableBalance: w.availableBalance,
        ),
      ],
    );
  }
}
