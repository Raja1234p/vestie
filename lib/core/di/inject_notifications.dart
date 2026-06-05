import '../../features/notifications/data/datasources/notifications_remote_data_source.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/usecases/notifications_usecases.dart';
import 'service_locator.dart';

/// Registers push notification list and device token APIs.
void registerNotificationsDependencies(ServiceLocator sl) {
  sl.notificationsRemoteDataSource =
      NotificationsRemoteDataSourceImpl(apiClient: sl.apiClient);
  sl.notificationsRepository = NotificationsRepositoryImpl(
    remoteDataSource: sl.notificationsRemoteDataSource,
  );
  sl.listNotificationsUseCase =
      ListNotificationsUseCase(sl.notificationsRepository);
  sl.markNotificationsReadUseCase =
      MarkNotificationsReadUseCase(sl.notificationsRepository);
  sl.registerDeviceTokenUseCase =
      RegisterDeviceTokenUseCase(sl.notificationsRepository);
  sl.unregisterDeviceTokenUseCase =
      UnregisterDeviceTokenUseCase(sl.notificationsRepository);
}
