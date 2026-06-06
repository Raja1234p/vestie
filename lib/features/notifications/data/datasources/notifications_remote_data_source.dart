import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/notification_api_models.dart';

abstract class NotificationsRemoteDataSource {
  Future<NotificationsPageModel> list({int page, int pageSize});

  Future<void> markRead(List<String> notificationIds);

  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  });

  Future<void> unregisterDeviceToken({required String token});
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final BaseApiClient apiClient;

  NotificationsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<NotificationsPageModel> list({int page = 1, int pageSize = 20}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.notifications,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return NotificationsPageModel.fromJson(response);
  }

  @override
  Future<void> markRead(List<String> notificationIds) async {
    await apiClient.post(
      ApiConstants.notificationsMarkRead,
      data: {'notificationIds': notificationIds},
    );
  }

  @override
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    await apiClient.post(
      ApiConstants.notificationsDeviceToken,
      data: {'token': token, 'platform': platform},
    );
  }

  @override
  Future<void> unregisterDeviceToken({required String token}) async {
    await apiClient.delete(
      ApiConstants.notificationsDeviceToken,
      data: {'token': token},
    );
  }
}
