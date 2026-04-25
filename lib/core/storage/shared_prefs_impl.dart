import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage.dart';

/// SharedPreferences-backed storage for non-sensitive flags (isLoggedIn, etc.).
class SharedPrefsImpl implements LocalStorage {
  final SharedPreferences _prefs;

  SharedPrefsImpl(this._prefs);

  @override
  Future<void> saveString(String key, String value) async =>
      _prefs.setString(key, value);

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<void> saveBool(String key, bool value) async =>
      _prefs.setBool(key, value);

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async =>
      _prefs.getBool(key) ?? defaultValue;

  @override
  Future<void> remove(String key) async => _prefs.remove(key);

  @override
  Future<void> clear() async => _prefs.clear();
}
