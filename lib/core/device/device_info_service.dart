import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../constants/storage_keys.dart';
import '../storage/secure_storage_impl.dart';
import 'device_identity.dart';

/// Resolves platform device id and display name for Android/iOS.
abstract class DeviceInfoService {
  Future<DeviceIdentity> getIdentity();
}

class DeviceInfoServiceImpl implements DeviceInfoService {
  DeviceInfoServiceImpl(this._secureStorage);

  final SecureStorageImpl _secureStorage;
  final DeviceInfoPlugin _plugin = DeviceInfoPlugin();
  DeviceIdentity? _cache;

  @override
  Future<DeviceIdentity> getIdentity() async {
    if (_cache != null) return _cache!;

    if (kIsWeb) {
      _cache = const DeviceIdentity(id: 'web', name: 'Web Browser');
      return _cache!;
    }

    if (Platform.isAndroid) {
      final info = await _plugin.androidInfo;
      final id = info.id.trim().isNotEmpty
          ? info.id.trim()
          : await _persistedFallbackId('android');
      _cache = DeviceIdentity(id: id, name: _androidDisplayName(info));
      return _cache!;
    }

    if (Platform.isIOS) {
      final info = await _plugin.iosInfo;
      final vendorId = info.identifierForVendor?.trim() ?? '';
      final id = vendorId.isNotEmpty
          ? vendorId
          : await _persistedFallbackId('ios');
      _cache = DeviceIdentity(id: id, name: _iosDisplayName(info));
      return _cache!;
    }

    _cache = DeviceIdentity(
      id: await _persistedFallbackId(Platform.operatingSystem),
      name: Platform.operatingSystem,
    );
    return _cache!;
  }

  /// iOS 16+ returns only `iPhone` / `iPad` for [IosDeviceInfo.name] unless the app
  /// holds Apple's `com.apple.developer.device-information.user-assigned-device-name`
  /// entitlement — use hardware model when the assigned name is not available.
  String _iosDisplayName(IosDeviceInfo info) {
    final assigned = info.name.trim();
    if (assigned.isNotEmpty &&
        assigned != 'iPhone' &&
        assigned != 'iPad' &&
        assigned != 'iPod touch') {
      return assigned;
    }

    final model = info.model.trim();
    if (model.isNotEmpty) return model;

    final machine = info.utsname.machine.trim();
    return machine.isNotEmpty ? machine : 'iOS';
  }

  String _androidDisplayName(AndroidDeviceInfo info) {
    final manufacturer = info.manufacturer.trim();
    final model = info.model.trim();
    if (manufacturer.isNotEmpty && model.isNotEmpty) {
      if (model.toLowerCase().startsWith(manufacturer.toLowerCase())) {
        return model;
      }
      return '$manufacturer $model';
    }
    if (model.isNotEmpty) return model;
    final device = info.device.trim();
    if (device.isNotEmpty) return device;
    return 'Android';
  }

  Future<String> _persistedFallbackId(String prefix) async {
    final stored = await _secureStorage.getString(StorageKeys.deviceInstallId);
    if (stored != null && stored.trim().isNotEmpty) {
      return stored.trim();
    }

    final generated =
        '$prefix-${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(this)}';
    await _secureStorage.saveString(StorageKeys.deviceInstallId, generated);
    return generated;
  }
}
