import '../../../core/constants/storage_keys.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/validation_utils.dart';
import '../../auth/domain/entities/user.dart';
import '../domain/entities/user_profile.dart';

/// Cached user profile written by dashboard / profile flows (`GET /users/me`).
abstract final class ProfilePrefs {
  static Future<UserProfile> load() async {
    final prefs = ServiceLocator.instance.sharedPrefs;
    var firstName = await prefs.getString(StorageKeys.userFirstName) ?? '';
    var lastName = await prefs.getString(StorageKeys.userLastName) ?? '';
    final email = await prefs.getString(StorageKeys.userEmail) ?? '';
    final handle = await prefs.getString(StorageKeys.userUsername) ?? '';
    final photo = await prefs.getString(StorageKeys.userPhotoUrl) ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      final legacyName = await prefs.getString(StorageKeys.userName) ?? '';
      final parts = ValidationUtils.splitFullNameParts(legacyName);
      firstName = parts.firstName;
      lastName = parts.lastName;
    }

    return UserProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      username: handle.isNotEmpty
          ? handle
          : (email.contains('@') ? email.split('@').first : ''),
      photoUrl: photo.isNotEmpty ? photo : null,
    );
  }

  static Future<void> persist(UserProfile profile) async {
    final prefs = ServiceLocator.instance.sharedPrefs;
    await prefs.saveString(StorageKeys.userFirstName, profile.firstName);
    await prefs.saveString(StorageKeys.userLastName, profile.lastName);
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
    await prefs.remove(StorageKeys.userFirstName);
    await prefs.remove(StorageKeys.userLastName);
    await prefs.remove(StorageKeys.userEmail);
    await prefs.remove(StorageKeys.userUsername);
    await prefs.remove(StorageKeys.userPhotoUrl);
  }

  static UserProfile fromUser(User user) {
    var firstName = user.firstName.trim();
    var lastName = user.lastName.trim();
    if (firstName.isEmpty && lastName.isEmpty) {
      final parts = ValidationUtils.splitFullNameParts(user.name);
      firstName = parts.firstName;
      lastName = parts.lastName;
    }

    final userName = user.userName.isNotEmpty
        ? user.userName
        : (user.email.contains('@') ? user.email.split('@').first : '');
    return UserProfile(
      firstName: firstName,
      lastName: lastName,
      email: user.email,
      username: userName,
      photoUrl: user.photoUrl,
    );
  }
}
