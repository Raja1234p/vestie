import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_strings.dart';
import '../constants/storage_keys.dart';
import '../di/service_locator.dart';
import '../theme/app_colors.dart';
import '../widgets/common/app_action_dialog.dart';
import 'app_snackbar.dart';

/// Runtime permission checks with user guidance when denied.
abstract final class AppPermissionHelper {
  AppPermissionHelper._();

  /// Camera or photo library access for [ImagePicker].
  static Future<bool> ensureImageSource(
    BuildContext context,
    ImageSource source,
  ) async {
    if (kIsWeb) return true;

    final permission = source == ImageSource.camera
        ? Permission.camera
        : _galleryPermission();

    var status = await permission.status;
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied || status.isRestricted) {
      if (context.mounted) {
        await _showOpenSettingsDialog(
          context,
          title: source == ImageSource.camera
              ? AppStrings.permissionCameraTitle
              : AppStrings.permissionPhotosTitle,
          description: source == ImageSource.camera
              ? AppStrings.permissionCameraSettingsBody
              : AppStrings.permissionPhotosSettingsBody,
        );
      }
      return false;
    }

    status = await permission.request();
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showOpenSettingsDialog(
          context,
          title: source == ImageSource.camera
              ? AppStrings.permissionCameraTitle
              : AppStrings.permissionPhotosTitle,
          description: source == ImageSource.camera
              ? AppStrings.permissionCameraSettingsBody
              : AppStrings.permissionPhotosSettingsBody,
        );
      }
      return false;
    }

    if (context.mounted) {
      AppSnackBar.showError(
        context,
        source == ImageSource.camera
            ? AppStrings.permissionCameraDenied
            : AppStrings.permissionPhotosDenied,
      );
    }
    return false;
  }

  /// Push notifications (FCM). On Android 13+ requests [POST_NOTIFICATIONS].
  static Future<bool> ensureNotifications(BuildContext context) async {
    if (kIsWeb) return true;

    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.requestPermission();
      final ok = _iosNotificationsGranted(settings.authorizationStatus);
      if (!ok && context.mounted) {
        await _showOpenSettingsDialog(
          context,
          title: AppStrings.permissionNotificationsTitle,
          description: AppStrings.permissionNotificationsSettingsBody,
        );
      }
      return ok;
    }

    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          await _showOpenSettingsDialog(
            context,
            title: AppStrings.permissionNotificationsTitle,
            description: AppStrings.permissionNotificationsSettingsBody,
          );
        }
        return false;
      }

      final result = await Permission.notification.request();
      if (result.isGranted) return true;

      if (result.isPermanentlyDenied && context.mounted) {
        await _showOpenSettingsDialog(
          context,
          title: AppStrings.permissionNotificationsTitle,
          description: AppStrings.permissionNotificationsSettingsBody,
        );
      } else if (context.mounted) {
        AppSnackBar.showError(
          context,
          AppStrings.permissionNotificationsDenied,
        );
      }
      return false;
    }

    return true;
  }

  /// Prompts for notification permission once per install.
  ///
  /// Call after the splash screen has painted (not during bootstrap).
  ///
  /// - Already granted → no-op.
  /// - Permanently denied → no-op (user must go to Settings manually).
  /// - Not determined / denied (promptable) → shows in-app dialog once, then marks dismissed.
  static Future<void> maybePromptNotifications(BuildContext context) async {
    if (kIsWeb || !context.mounted) return;

    // Already granted — nothing to do.
    final granted = await _notificationsAlreadyGranted();
    if (granted) return;

    if (!context.mounted) return;

    // On Android, check if permanently denied — don't bother prompting.
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isPermanentlyDenied) return;
    }

    final prefs = ServiceLocator.instance.sharedPrefs;
    if (await prefs.getBool(
          StorageKeys.notificationPermissionPromptDismissed,
        ) ==
        true) {
      return;
    }

    if (!context.mounted) return;

    await AppActionDialog.show(
      context,
      title: AppStrings.permissionNotificationsTitle,
      description: AppStrings.permissionNotificationsPromptBody,
      primaryLabel: AppStrings.btnEnableNotifications,
      secondaryLabel: AppStrings.btnNotNow,
      showSecondary: true,
      primaryColor: AppColors.primary,
      onPrimary: () {
        Navigator.of(context).pop();
        ensureNotifications(context);
      },
    );

    await prefs.saveBool(
      StorageKeys.notificationPermissionPromptDismissed,
      true,
    );
  }

  static Future<bool> _notificationsAlreadyGranted() async {
    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      return _iosNotificationsGranted(settings.authorizationStatus);
    }
    if (Platform.isAndroid) {
      return (await Permission.notification.status).isGranted;
    }
    return true;
  }

  static bool _iosNotificationsGranted(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  static Permission _galleryPermission() {
    if (Platform.isAndroid) {
      return Permission.photos;
    }
    return Permission.photos;
  }

  static Future<void> _showOpenSettingsDialog(
    BuildContext context, {
    required String title,
    required String description,
  }) async {
    if (!context.mounted) return;

    await AppActionDialog.show(
      context,
      title: title,
      description: description,
      primaryLabel: AppStrings.btnOpenSettings,
      secondaryLabel: AppStrings.btnCancel,
      showSecondary: true,
      primaryColor: AppColors.primary,
      onPrimary: () {
        Navigator.of(context).pop();
        openAppSettings();
      },
    );
  }
}
