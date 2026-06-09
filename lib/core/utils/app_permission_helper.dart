import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../widgets/common/app_action_dialog.dart';
import '../widgets/common/app_toast.dart';

/// Camera / gallery permission — on user action only (profile photo).
///
/// Notifications: [FcmPushService.initialize] via flutter_local_notifications
/// (`requestAlertPermission: true` on iOS, `requestNotificationsPermission` on Android).
abstract final class AppPermissionHelper {
  AppPermissionHelper._();

  /// Call before [ImagePicker.pickImage]. iOS uses image_picker / PHPicker directly.
  static Future<bool> ensureImageSource(
    BuildContext context,
    ImageSource source,
  ) async {
    if (kIsWeb || Platform.isIOS) return true;

    final permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;

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

    if (!context.mounted) return false;

    if (status.isPermanentlyDenied) {
      await _showOpenSettingsDialog(
        context,
        title: source == ImageSource.camera
            ? AppStrings.permissionCameraTitle
            : AppStrings.permissionPhotosTitle,
        description: source == ImageSource.camera
            ? AppStrings.permissionCameraSettingsBody
            : AppStrings.permissionPhotosSettingsBody,
      );
    } else {
      AppToast.showError(
        context,
        source == ImageSource.camera
            ? AppStrings.permissionCameraDenied
            : AppStrings.permissionPhotosDenied,
      );
    }
    return false;
  }

  static bool galleryPickRequestsFullMetadata(ImageSource source) {
    return source == ImageSource.gallery;
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
