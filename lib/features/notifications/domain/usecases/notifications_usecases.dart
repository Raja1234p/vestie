import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/app_notification_entity.dart';
import '../repositories/notifications_repository.dart';

class ListNotificationsUseCase {
  final NotificationsRepository repository;

  ListNotificationsUseCase(this.repository);

  Future<Either<Failure, NotificationsPageEntity>> call({
    int page = 1,
    int pageSize = 20,
  }) =>
      repository.list(page: page, pageSize: pageSize);
}

class MarkNotificationsReadUseCase {
  final NotificationsRepository repository;

  MarkNotificationsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(List<String> notificationIds) =>
      repository.markRead(notificationIds);
}

class RegisterDeviceTokenUseCase {
  final NotificationsRepository repository;

  RegisterDeviceTokenUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String token,
    required String platform,
  }) =>
      repository.registerDeviceToken(token: token, platform: platform);
}

class UnregisterDeviceTokenUseCase {
  final NotificationsRepository repository;

  UnregisterDeviceTokenUseCase(this.repository);

  Future<Either<Failure, void>> call({required String token}) =>
      repository.unregisterDeviceToken(token: token);
}
