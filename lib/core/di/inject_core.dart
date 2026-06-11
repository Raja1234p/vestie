import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/projects/data/datasources/project_local_data_source.dart';
import '../device/device_info_service.dart';
import '../network/base_api_client.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../storage/secure_storage_impl.dart';
import '../storage/shared_prefs_impl.dart';
import 'service_locator.dart';

/// Registers Dio, storage, connectivity, and [BaseApiClient].
Future<void> registerCoreDependencies(ServiceLocator sl) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.sharedPrefs = SharedPrefsImpl(sharedPreferences);
  sl.secureStorage = SecureStorageImpl();
  sl.deviceInfoService = DeviceInfoServiceImpl(sl.secureStorage);
  sl.dioClient = DioClient(
    secureStorage: sl.secureStorage,
    deviceInfoService: sl.deviceInfoService,
  );
  sl.apiClient = BaseApiClient(dio: sl.dioClient.dio);
  sl.connectivity = Connectivity();
  sl.networkInfo = NetworkInfoImpl(sl.connectivity);
  sl.projectLocalDataSource = ProjectLocalDataSourceImpl(
    localStorage: sl.sharedPrefs,
  );
}
