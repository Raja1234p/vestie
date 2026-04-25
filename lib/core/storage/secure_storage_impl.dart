import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'local_storage.dart';

/// Secure token store backed by FlutterSecureStorage (Keychain / Keystore).
/// Use this for access tokens, refresh tokens — any sensitive credential.
class SecureStorageImpl implements LocalStorage {
  final FlutterSecureStorage _storage;

  SecureStorageImpl()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(),
        );

  @override
  Future<void> saveString(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> getString(String key) => _storage.read(key: key);

  @override
  Future<void> saveBool(String key, bool value) =>
      _storage.write(key: key, value: value.toString());

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final raw = await _storage.read(key: key);
    if (raw == null) return defaultValue;
    return raw == 'true';
  }

  @override
  Future<void> remove(String key) => _storage.delete(key: key);

  @override
  Future<void> clear() => _storage.deleteAll();
}
