import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/app_notification_entity.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, NotificationsPageEntity>> list({
    int page,
    int pageSize,
  });

  Future<Either<Failure, void>> markRead(List<String> notificationIds);

  Future<Either<Failure, void>> registerDeviceToken({
    required String token,
    required String platform,
  });

  Future<Either<Failure, void>> unregisterDeviceToken({required String token});
}
