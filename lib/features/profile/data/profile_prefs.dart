import '../../../core/constants/storage_keys.dart';
import '../../../core/di/service_locator.dart';
import '../../auth/domain/entities/user.dart';
import '../domain/entities/user_profile.dart';

/// Cached user profile written by dashboard / profile flows (`GET /users/me`).
abstract final class ProfilePrefs {
  static Future<UserProfile> load() async {
    final prefs = ServiceLocator.instance.sharedPrefs;
    final name = await prefs.getString(StorageKeys.userName) ?? '';
    final email = await prefs.getString(StorageKeys.userEmail) ?? '';
    final handle = await prefs.getString(StorageKeys.userUsername) ?? '';
    final photo = await prefs.getString(StorageKeys.userPhotoUrl) ?? '';

    return UserProfile(
      fullName: name,
      email: email,
      username: handle.isNotEmpty
          ? handle
          : (email.contains('@') ? email.split('@').first : ''),
      photoUrl: photo.isNotEmpty ? photo : null,
    );
  }

  static Future<void> persist(UserProfile profile) async {
    final prefs = ServiceLocator.instance.sharedPrefs;
    await prefs.saveString(StorageKeys.userName, profile.fullName);
    await prefs.saveString(StorageKeys.userEmail, profile.email);
    await prefs.saveString(StorageKeys.userUsername, profile.username);
    final photo = profile.photoUrl?.trim();
    if (photo != null && photo.isNotEmpty) {
      await prefs.saveString(StorageKeys.userPhotoUrl, photo);
    } else {
      await prefs.remove(StorageKeys.userPhotoUrl);
    }
  }

  /// Clears cached profile fields (call on logout / forced sign-out).
  static Future<void> clear() async {
    final prefs = ServiceLocator.instance.sharedPrefs;
    await prefs.remove(StorageKeys.userName);
    await prefs.remove(StorageKeys.userEmail);
    await prefs.remove(StorageKeys.userUsername);
    await prefs.remove(StorageKeys.userPhotoUrl);
  }

  static UserProfile fromUser(User user) {
    final userName = user.userName.isNotEmpty
        ? user.userName
        : (user.email.contains('@') ? user.email.split('@').first : '');
    return UserProfile(
      fullName: user.name,
      email: user.email,
      username: userName,
      photoUrl: user.photoUrl,
    );
  }
}
