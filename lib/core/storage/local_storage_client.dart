abstract class LocalStorageClient {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

// A simple interface definition. Actual implementation should be mapped to SharedPreferences or Hive.
class SharedPreferencesClient implements LocalStorageClient {
  // final SharedPreferences sharedPreferences;

  // SharedPreferencesClient({required this.sharedPreferences});

  @override
  Future<void> saveString(String key, String value) async {
    // await sharedPreferences.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    // return sharedPreferences.getString(key);
    return null;
  }

  @override
  Future<void> remove(String key) async {
    // await sharedPreferences.remove(key);
  }

  @override
  Future<void> clear() async {
    // await sharedPreferences.clear();
  }
}
