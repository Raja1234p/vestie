/// Enterprise Interface for Local Storage 
abstract class LocalStorage {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool> getBool(String key, {bool defaultValue = false});
  Future<void> remove(String key);
  Future<void> clear();
}

/// Use Shared Preferences or Flutter Secure Storage to implement this interface.
/// E.g. class SecureStorageImpl implements LocalStorage { ... }
