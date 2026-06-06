import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:vestie/features/notifications/domain/repositories/notifications_repository.dart';

import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, NotificationsPageEntity>> list({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final pageModel = await remoteDataSource.list(
        page: page,
        pageSize: pageSize,
      );
      return Right(pageModel);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> markRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return const Right(null);
    try {
      await remoteDataSource.markRead(notificationIds);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    if (token.trim().isEmpty) return const Right(null);
    try {
      await remoteDataSource.registerDeviceToken(
        token: token,
        platform: platform,
      );
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> unregisterDeviceToken({
    required String token,
  }) async {
    if (token.trim().isEmpty) return const Right(null);
    try {
      await remoteDataSource.unregisterDeviceToken(token: token);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
